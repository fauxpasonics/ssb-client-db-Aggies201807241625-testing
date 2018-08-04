SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop procedure [amy].[rpt_DonorStudentMembershipReportGrid]
--exec [amy].[rpt_DonorStudentMembershipReportGrid] '01/01/2017', '12/31/2017'

CREATE PROCEDURE [amy].[rpt_DonorStudentMembershipReportGrid] (@startdate date = '01/01/2015', @enddate  date = '12/31/2015')

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @CurrentYearDT int
Declare @yearstartdate date
DECLARE @MEMBID INT
Declare  @yearenddate  datetime
Declare  @enddatetime  datetime
DECLARE @MEMBCODE varchar(20)

SET @CurrentYear   = cast( year (@startdate) as varchar);
SET @CurrentYearDT = year (@startdate) ;
Set @yearstartdate = cast ('01/01/' + @CurrentYear AS DATE);
--SET @MEMBID = (   SELECT MEMBID FROM ADVMembership  mm3 
--                         WHERE mm3.membershipname = 'Student Membership'  and mm3.driveyear =  @CurrentYear );

                                                 
 Set @yearenddate = cast ('12/31/' + @CurrentYear + ' 23:59:59' AS DATEtime);      
 
 Set  @enddatetime  = cast( cast(  @enddate as varchar) + ' 23:59:59' AS DATEtime);  
 
  select @MEMBCODE = 'STUDENT'

SELECT  t.adnumber, firstname, lastname, address1, address2, address3, city, state, zip, email, 
      case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 15) and  enrolldate between @startdate and @yearenddate  
      then 'X' else null end [Renewal],
     case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 15 and   Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <15) then 'X' else null end    "Student Member",      
     case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 30 and   Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <30) then 'X' else null end    "Student Leader",
            EnrollDate, 
            LastupdateDate,
       @startdate Start_Date,
       @enddatetime  End_Date
  FROM (SELECT c.contactid,
  c.adnumber,
               c.firstname,
               c.lastname,
               c.email,
               c.SetupDate,
               c.status,
               c.DonorType,
               c.adj_Address1 Address1,
               c.adj_Address2 Address2,
               c.adj_Address3 address3,
               c.City,
               c.State,
               c.Zip,
               c.Salutation,
               ytd_all.YTD_CAP_Receipt,
               ytd_all.YTD_Annual_Receipt,
               ytd_all.YTD_Total,
               ytd_all.YTD_Trans,
               ytd_all.YTD_Match,
               ytd_all.YTD_Credit_Total,
               ytd_all.YTD_CAP_Receipt + YTD_Annual_Receipt + ytd_all.YTD_Credit_Total   YTD_ALL,
               ytd_all.This_Week_CAP_Receipt,
               ytd_all.This_Week_Annual_Receipt,
               ytd_all.This_Week_Total_Receipt,
               ytd_all.This_Week_Total_Credit,
               ytd_all.This_Week_Trans_Amount_Receipt,
               ytd_all.This_Week_Match_Amount_Receipt,
               ytd_all.Previous_YTD_CAP_Receipt,
               ytd_all.Previous_YTD_Annual_Receipt,
               ytd_all.Previous_YTD_Total,
               ytd_all.Previous_YTD_Trans,
               ytd_all.Previous_YTD_Match,
               ytd_all.Previous_YTD_Credit, 
               EnrollDate, 
               LastupdateDate,
               --ytd_all.Programs_Count Allocation_Count,
               --case when ytd_all.Programs_Count = 1 then  ytd_all.MaxProgramName else '((Multiple Allocations))' end Allocation_Name,
               mbrl.levelname,
               mbr_prev.levelname previous_level, donortypecode, donorstatuscode
          FROM amy.PatronExtendedInfo_vw c
               JOIN
               (SELECT h.acct,
                       al.MembID,
                       al.driveyear,
                       SUM (
                          CASE
                             WHEN    isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <>0 
                                  AND h.driveyear = 0
                                  AND receiveddate<=  @enddatetime 
                             THEN
                                isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS YTD_CAP_Receipt,
                       SUM (
                          CASE
                             WHEN    isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <>0 
                                  AND h.driveyear <> 0
                                  AND receiveddate<=  @enddatetime 
                             THEN
                               isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS YTD_Annual_Receipt,
                       sUM (
                          CASE
                             WHEN     isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <> 0
                                  AND receiveddate<= @enddatetime 
                             THEN
                                  isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0)
                             ELSE
                                0
                          END)
                          AS YTD_Total,
                       sUM (
                          CASE
                             WHEN     CreditAmt <> 0 
                                  AND receiveddate<=  @enddatetime 
                             THEN
                                CreditAmt
                             ELSE
                                0
                          END)
                          AS YTD_CREDIT_Total,
                       SUM (
                          CASE
                             WHEN      isnull(PaymentAmt,0)  <> 0
                                  AND receiveddate<=  @enddatetime 
                             THEN
                                  isnull(PaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS YTD_Trans,
                       SUM (
                          CASE
                             WHEN     isnull(MatchingPaymentAmt,0) <> 0
                                  AND receiveddate<=  @enddatetime 
                             THEN
                                 isnull(MatchingPaymentAmt,0)
                             ELSE
                                0
                          END)
                          AS YTD_Match,
                       SUM (
                          CASE
                             WHEN      isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <> 0
                                  AND h.driveyear = 0
                                  AND receiveddate BETWEEN @startdate
                                                    AND @enddatetime 
                             THEN
                                  isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS This_Week_CAP_Receipt,
                       SUM (
                          CASE
                             WHEN      isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <> 0
                                  AND h.driveyear <>  0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) BETWEEN @startdate
                                                AND @enddatetime 
                             THEN
                                  isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS This_Week_Annual_Receipt,
                       SUM (
                          CASE
                             WHEN       isnull(PaymentAmt,0)  <> 0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) BETWEEN @startdate
                                                AND @enddatetime 
                             THEN
                                  isnull(PaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS This_Week_Trans_Amount_Receipt,
                       SUM (
                          CASE
                             WHEN       isnull(MatchingPaymentAmt,0) <> 0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) BETWEEN @startdate
                                                AND @enddatetime 
                             THEN
                                 isnull(MatchingPaymentAmt,0)
                             ELSE
                                0
                          END)
                          AS This_Week_Match_Amount_Receipt,
                       SUM (
                          CASE
                             WHEN       isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <> 0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) BETWEEN @startdate
                                                AND @enddatetime 
                             THEN
                                  isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS This_Week_Total_Receipt,
                                                 SUM (
                          CASE
                             WHEN     CreditAmt <> 0 
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) BETWEEN @startdate
                                                AND @enddatetime 
                             THEN
                                  CreditAmt
                             ELSE
                                0
                          END)
                          AS This_Week_Total_Credit,
                       SUM (
                          CASE
                             WHEN      isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <> 0
                                  AND h.driveyear = 0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) < @startdate
                             THEN
                                 isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS Previous_YTD_CAP_Receipt,
                       SUM (
                          CASE
                             WHEN       isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <> 0
                                  AND h.driveyear <> 0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) < @startdate
                             THEN
                                isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0)
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Annual_Receipt,
                       SUM (
                          CASE
                             WHEN     isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0) <>0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) < @startdate
                             THEN
                                isnull(PaymentAmt,0) +isnull(MatchingPaymentAmt,0)
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Total,
                       SUM (
                          CASE
                             WHEN     isnull(PaymentAmt,0)  <>0
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) < @startdate
                             THEN
                                isnull(PaymentAmt,0) 
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Trans,
                       SUM (
                          CASE
                             WHEN    isnull(MatchingPaymentAmt,0) <> 0 
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) < @startdate
                             THEN
                               isnull(MatchingPaymentAmt,0)
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Match , 
                                                 SUM (
                          CASE
                             WHEN     CreditAmt <> 0 
                                  AND (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END) < @startdate
                             THEN
                               CreditAmt
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Credit  ,
                           min(CASE
                             WHEN   isnull(PaymentAmt,0) <> 0 or isnull(MatchingPaymentAmt,0) <> 0  or isnull(CreditAmt,0) <>0
                             THEN
                                (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END)
                             ELSE
                                null
                          END)   EnrollDate, 
                            max ( CASE
                             WHEN    isnull(PaymentAmt,0) <> 0 or isnull(MatchingPaymentAmt,0) <> 0  or isnull(CreditAmt,0) <>0
                             THEN
                               (CASE
                                          WHEN year (receiveddate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             receiveddate
                                       END)
                             ELSE
                                null
                          END) LastupdateDate
                  --   count(distinct (case when transtype like '%Receipt%' and ((h.driveyear = 'CAP'  and receiveddatebetween @startdate and @yearenddate )
                  --       or (h.driveyear <> 'CAP'  and (case when year(receiveddate) < year(@startdate) then cast('01/01/'+ cast(year(@startdate) as varchar) as date) else receiveddateend)  between @startdate and @yearenddate  )) then l.programid else null end ) ) Programs_Count,
                  --    max(case when transtype like '%Receipt%' and ((h.driveyear = 'CAP'  and receiveddatebetween @startdate and @yearenddate )
                  --       or (h.driveyear <> 'CAP'  and (case when year(receiveddate) < year(@startdate) then cast('01/01/'+ cast(year(@startdate) as varchar) as date) else receiveddateend)  between @startdate and @yearenddate  )) then p.programname else null end  ) MaxProgramName
                  --select *
                   FROM amy.PacTranItem_alt_vw  h
                        INNER JOIN (select alll.AllocationID ,  alll.MembershipID membid , alll.DriveYear from 
                          ods.PAC_MembershipContributingAllocation alll WHERE  alll.MembershipID =@MEMBCODE AND alll.DriveYear = @CurrentYearDT 
                           ) al
                          ON    h.AllocationID  = al.AllocationID      
                             AND al.DriveYear = @CurrentYearDT 
                where  (   h.driveyear =@CurrentYear
                                  OR (    h.driveyear = 0
                                      AND format( receiveddate, 'MM/dd/yyyy')  between @yearstartdate and  @yearenddate))
                GROUP BY h.acct, al.MembID, al.driveyear) YTD_ALL
                  ON c.patron= YTD_ALL.acct
               LEFT JOIN
               ( select  * from pac_Membership_Ranges_vw m  where  m.membiD = @membcode and m.driveyear = @CurrentYearDT  ) mbrl
  ON     ytd_all.membid = mbrl.membid
                     AND ytd_all.YTD_CAP_Receipt + YTD_Annual_Receipt + ytd_all.YTD_Credit_Total BETWEEN mbrl.MinAmount
                                                                          AND mbrl.maxamount
               LEFT JOIN
               (select  * from pac_Membership_Ranges_vw m  where  m.membiD = @membcode and m.driveyear = @CurrentYearDT  ) mbr_prev
                  ON     ytd_all.membid = mbr_prev.membid
                     AND   Previous_YTD_CAP_Receipt
                         + Previous_YTD_Annual_Receipt + Previous_YTD_Credit BETWEEN mbr_prev.MinAmount
                                                           AND mbr_prev.maxamount)
       AS t
 WHERE 
DonorStatusCode not in ('NB','D') -- and donortype not like '%New Grad%'
and YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 15
and (enrolldate between @startdate and  @enddatetime  or 
(LastupdateDate between @startdate and  @enddatetime   and isnull(previous_level, 'New') <> levelname and YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total > Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit ) )
order by adnumber
GO
