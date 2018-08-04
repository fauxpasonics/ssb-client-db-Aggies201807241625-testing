SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[rpt_DonorMembershipReportGridalt] '01/01/2017',  '12/31/2017'
CREATE PROCEDURE [amy].[rpt_DonorMembershipReportGridalt] (@startdate date = '01/01/2015', @enddate date = '12/31/2015')

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @CurrentYearDT int
Declare @yearstartdate date
DECLARE @MEMBID INT

SET @CurrentYear   = cast( year (@startdate) as varchar);
SET @CurrentYearDT = year (@startdate) ;
Set @yearstartdate = cast ('01/01/' + @CurrentYear AS DATE);
SET @MEMBID = (   SELECT MEMBID FROM ADVMembership  mm3 
                         WHERE mm3.membershipname = '12th Man Foundation - All' and mm3.transyear =  @CurrentYear );
SELECT  t.adnumber, firstname, lastname, address1, address2, address3, city, state, zip, email, 
      case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 25) and  enroll2date between @startdate and @enddate 
      then 'X' else null end [Renewal],
      case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 25 and   Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <25) then 'X' else null end    [Reveille],
      case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 150 and   Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <150) then 'X' else null end    [Silvver Reveille],
case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 500 and   Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <500) then 'X' else null end    [Gold Reveille],
case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 1000 and Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <1000)   then 'X' else null end [Platinum Reveille],
case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 5000 and Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <5000)   then 'X' else null end [The 12th Man],
case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 10000 and  Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <10000)  then 'X' else null end   [Silver 12th Man],
case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 15000 and  Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <15000)   then 'X' else null end    [Gold 12th Man],
case when ( YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 20000 and Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <20000)   then 'X' else null end  [Platinum 12th Man],
case when (YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 25000 and Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit <25000)  then 'X' else null end  [Diamond 12th Man]     ,
          enroll2date    EnrollDate, 
            LastupdateDate,
       @startdate Start_Date,
       @enddate End_Date,
       levelname,
       previous_level, 
       enroll2date
  FROM (SELECT c.contactid,
  c.adnumber,
               c.firstname,
               c.lastname,
               c.email,
               c.SetupDate,
               c.status,
               c.udf2 DonorType,
               ca.Address1,
               ca.Address2,
               ca.address3,
               ca.City,
               ca.State,
               ca.Zip,
               ca.Salutation,
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
               mbr_prev.levelname previous_level,          
   (  select CASE   when dt is null then null
                                          WHEN year (dt) <  @CurrentYearDT  THEN      @yearstartdate
                                          ELSE  dt     END 
                                          from ( select min(transdate)  dt from (
               select   h.contactid, al.MembID, al.TransYear   ,  h.transdate,  
               (case when transtype like '%Receipt%' or transtype like '%Credit%' then Transamount + MatchAmount else 0 end) tt,
                SUM(case when transtype like '%Receipt%' or transtype like '%Credit%' then Transamount + MatchAmount else 0 end) OVER ( partition by h.contactid 
                ORDER BY transdate rows between unbounded preceding and current row )  enroll2
                   FROM dbo.advContactTransHeader h
                       INNER JOIN dbo.advContactTransLineItems l
                          ON     h.transid = l.transid
                             AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear
                                  OR (    h.TransYear = 'CAP'
                                      AND transdate >=@yearstartdate))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from 
                          dbo.advAllocationLevels  alll WHERE MEMBID =@MEMBID AND TRANSYEAR = @CurrentYear
                           ) al
                          ON     l.ProgramID = al.ProgramID          
                             AND al.TransYear = @CurrentYear
                       INNER JOIN dbo.advprogram p ON p.programid = l.programid ) j
                       where enroll2 >= 25 and contactid = ytd_all.contactid ) ttt              
               ) Enroll2date
          FROM advcontact c
               left JOIN amy.advcontactaddresses_unique_primary_vw ca
                  ON c.ContactID = ca.ContactID  --AND ca.PrimaryAddress = 1
               JOIN
               (SELECT h.contactid,
                       al.MembID,
                       al.TransYear,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND h.transyear = 'CAP'
                                  AND transdate <= @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS YTD_CAP_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND h.transyear <> 'CAP'
                                  AND transdate <= @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS YTD_Annual_Receipt,
                       sUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND transdate <= @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS YTD_Total,
                       sUM (
                          CASE
                             WHEN     transtype LIKE '%Credit%'
                                  AND transdate <= @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS YTD_CREDIT_Total,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND transdate <= @enddate
                             THEN
                                transamount
                             ELSE
                                0
                          END)
                          AS YTD_Trans,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND transdate <= @enddate
                             THEN
                                matchamount
                             ELSE
                                0
                          END)
                          AS YTD_Match,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND h.transyear = 'CAP'
                                  AND transdate BETWEEN @startdate
                                                    AND @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS This_Week_CAP_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND h.transyear <> 'CAP'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) BETWEEN @startdate
                                                AND @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS This_Week_Annual_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) BETWEEN @startdate
                                                AND @enddate
                             THEN
                                transamount
                             ELSE
                                0
                          END)
                          AS This_Week_Trans_Amount_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) BETWEEN @startdate
                                                AND @enddate
                             THEN
                                matchamount
                             ELSE
                                0
                          END)
                          AS This_Week_Match_Amount_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) BETWEEN @startdate
                                                AND @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS This_Week_Total_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Credit%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) BETWEEN @startdate
                                                AND @enddate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS This_Week_Total_Credit,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND h.transyear = 'CAP'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) < @startdate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_CAP_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND h.transyear <> 'CAP'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) < @startdate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Annual_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) < @startdate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Total,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) < @startdate
                             THEN
                                transamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Trans,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) < @startdate
                             THEN
                                matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Match , 
                                                 SUM (
                          CASE
                             WHEN     transtype LIKE '%Credit%'
                                  AND (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END) < @startdate
                             THEN
                                transamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Credit  ,
                           min(CASE
                             WHEN     transtype LIKE '%Receipt%' or transtype like '%Credit%'
                             THEN
                                (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END)
                             ELSE
                                null
                          END)   EnrollDate, 
                            max ( CASE
                             WHEN     transtype LIKE '%Receipt%' or transtype like '%Credit%'
                             THEN
                               (CASE
                                          WHEN year (transdate) <  @CurrentYearDT
                                          THEN
                                             @yearstartdate
                                          ELSE
                                             transdate
                                       END)
                             ELSE
                                null
                          END) LastupdateDate
                  --   count(distinct (case when transtype like '%Receipt%' and ((h.transyear = 'CAP'  and transdate between @startdate and @enddate)
                  --       or (h.transyear <> 'CAP'  and (case when year(transdate) < year(@startdate) then cast('01/01/'+ cast(year(@startdate) as varchar) as date) else transdate end)  between @startdate and @enddate )) then l.programid else null end ) ) Programs_Count,
                  --    max(case when transtype like '%Receipt%' and ((h.transyear = 'CAP'  and transdate between @startdate and @enddate)
                  --       or (h.transyear <> 'CAP'  and (case when year(transdate) < year(@startdate) then cast('01/01/'+ cast(year(@startdate) as varchar) as date) else transdate end)  between @startdate and @enddate )) then p.programname else null end  ) MaxProgramName
                  --select *
                   FROM dbo.advContactTransHeader h
                       INNER JOIN dbo.advContactTransLineItems l
                          ON     h.transid = l.transid
                             AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear
                                  OR (    h.TransYear = 'CAP'
                                      AND transdate >=@yearstartdate))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from 
                          dbo.advAllocationLevels  alll WHERE MEMBID =@MEMBID AND TRANSYEAR = @CurrentYear
                           ) al
                          ON     l.ProgramID = al.ProgramID          
                             AND al.TransYear = @CurrentYear
                       INNER JOIN dbo.advprogram p ON p.programid = l.programid
                GROUP BY h.contactid, al.MembID, al.TransYear) YTD_ALL
                  ON c.ContactID = YTD_ALL.ContactID
               LEFT JOIN
               ( SELECT ml.membid,
                       ml.levelid,
                       ml.levelname,
                       ml.minamount,
                       isnull (min (ml2.minamount - .0001), 1000000000)
                          maxamount
                  FROM dbo.advMembershipLevels ml
                       LEFT JOIN dbo.advMembershipLevels ml2
                          ON     ml.membid = ml2.membid
                             AND ml2.minamount > ml.minamount
                             and ml2.membid  = @MEMBID
                    where ml.membid  = @MEMBID
                GROUP BY ml.membid,
                         ml.levelid,
                         ml.levelname,
                         ml.minamount) mbrl
  ON     ytd_all.membid = mbrl.membid
                     AND ytd_all.YTD_CAP_Receipt + YTD_Annual_Receipt + ytd_all.YTD_Credit_Total BETWEEN mbrl.MinAmount
                                                                          AND mbrl.maxamount
               LEFT JOIN
               ( SELECT ml.membid,
                       ml.levelid,
                       ml.levelname,
                       ml.minamount,
                       isnull (min (ml2.minamount - .0001), 1000000000)
                          maxamount
                  FROM dbo.advMembershipLevels ml
                       LEFT JOIN dbo.advMembershipLevels ml2
                          ON     ml.membid = ml2.membid
                             AND ml2.minamount > ml.minamount
                             and ml2.membid  = @MEMBID
                    where ml.membid  = @MEMBID
                GROUP BY ml.membid,
                         ml.levelid,
                         ml.levelname,
                         ml.minamount) mbr_prev
                  ON     ytd_all.membid = mbr_prev.membid
                     AND   Previous_YTD_CAP_Receipt
                         + Previous_YTD_Annual_Receipt + Previous_YTD_Credit BETWEEN mbr_prev.MinAmount
                                                           AND mbr_prev.maxamount)
       AS t
 WHERE 
status not in ('No Benefits','Deceased') -- and donortype not like '%New Grad%'
and YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total >= 25 
and (enrolldate between @startdate and @enddate or 
(LastupdateDate between @startdate and @enddate and isnull(previous_level, 'New') <> levelname and YTD_CAP_Receipt + YTD_Annual_Receipt + YTD_Credit_Total > Previous_YTD_CAP_Receipt + Previous_YTD_Annual_Receipt + Previous_YTD_Credit ) )
order by adnumber
GO
