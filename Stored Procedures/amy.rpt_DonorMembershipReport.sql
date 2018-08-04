SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec  [rpt_DonorMembershipReport] '01/01/2015', '12/01/2015'
--drop procedure rpt_DonorMembershipReport
CREATE PROCEDURE [amy].[rpt_DonorMembershipReport] (@startdate date = '01/01/2015', @enddate date = '12/31/2015')

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

SELECT t.*,
       CASE
          WHEN SetupDate BETWEEN @startdate AND @enddate THEN 'X'
          ELSE NULL
       END
          New_Member,
       CASE WHEN previous_level <> levelname THEN 'X' ELSE NULL END New_Level,
       @startdate Start_Date,
       @enddate End_Date
  FROM (SELECT c.contactid,
  c.adnumber,
               c.firstname,
               c.lastname,
               c.email,
               c.SetupDate,
               c.status,
               ca.Address1,
               ca.Address2,
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
               mbrl.levelname,
               mbr_prev.levelname previous_level, 
               RenewalDate
          FROM dbo.advcontact c
               left JOIN dbo.advcontactaddresses ca
                  ON c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1
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
                                          WHEN year (transdate) < @CurrentYearDT
                                          THEN @yearstartdate
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
                                          WHEN year (transdate) < @CurrentYearDT
                                          THEN @yearstartdate  ELSE   transdate
                                       END) BETWEEN @startdate AND @enddate
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
                                          THEN @yearstartdate
                                          ELSE
                                             transdate
                                       END) BETWEEN @startdate   AND @enddate
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
                                  AND transdate < @startdate
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
                                  AND transdate < @startdate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Annual_Receipt,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND transdate < @startdate
                             THEN
                                transamount + matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Total,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND transdate < @startdate
                             THEN
                                transamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Trans,
                       SUM (
                          CASE
                             WHEN     transtype LIKE '%Receipt%'
                                  AND transdate < @startdate
                             THEN
                                matchamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Match , 
                                                 SUM (
                          CASE
                             WHEN     transtype LIKE '%Credit%'
                                  AND transdate < @startdate
                             THEN
                                transamount
                             ELSE
                                0
                          END)
                          AS Previous_YTD_Credit ,
                          min(transdate) RenewalDate                          
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
 WHERE This_Week_CAP_Receipt + This_Week_Annual_Receipt +This_Week_Total_Credit> 0
and status not in ('No Benefits', 'Deceased')
GO
