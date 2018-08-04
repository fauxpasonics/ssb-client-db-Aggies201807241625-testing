SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_execdash_refresh]  as
DECLARE @CurrentYear VARCHAR(20)
DECLARE @CurrentYearDT int
--Declare @yearstartdate date
DECLARE @MEMBID INT
DECLARE @StudentMEMBID INT

declare tixcursor CURSOR LOCAL FAST_FORWARD FOR  select year(getdate()) yr  union select year(getdate())-1 yr  union select year(getdate())-2 yr  ;

begin
 delete from amy.rpt_execdash_ticket_summary_tb
 insert into amy.rpt_execdash_ticket_summary_tb select *  from  amy.rpt_execdash_ticket_summary_vw 

 OPEN tixCursor
         FETCH NEXT FROM TixCursor
              INTO @CurrentYearDT 
              
   
         WHILE @@FETCH_STATUS = 0
   BEGIN           
SET @CurrentYear   = cast( @CurrentYearDT  as varchar);
--Set @yearstartdate = cast ('01/01/' + @CurrentYear AS DATE);
SET @MEMBID = (   SELECT MEMBID FROM ADVMembership  mm3  WHERE mm3.membershipname = '12th Man Foundation - All' and mm3.transyear =  @CurrentYear );
SET @StudentMEMBID = (   SELECT MEMBID FROM ADVMembership  mm3  WHERE mm3.membershipname = 'Student Membership' and mm3.transyear =  @CurrentYear );                      

delete from  rpt_execdash_MembershipCounts_tb where Year = @CurrentYear 

insert  into rpt_execdash_MembershipCounts_tb
SELECT  @CurrentYear Year,
  case when levelname is null then 'Lifetime' else levelname end levelname,  minamount,  maxamount, 
  count(distinct adnumber) YTD_cnt,
  getdate() update_date 
  FROM (SELECT c.contactid,  c.adnumber, c.firstname, c.lastname, c.email, c.SetupDate, ytd_all.status, c.udf2 DonorType,
               ytd_all.YTD_Receipt,  ytd_all.YTD_Credit_Total, 
               ytd_all.YTD_Receipt  + ytd_all.YTD_Credit_Total   YTD_ALL,
               EnrollDate,  mbrl.levelname,    mbrl.minamount,  mbrl.maxamount
          FROM advcontact c  JOIN
               (SELECT h.contactid,  al.MembID,  al.TransYear, c.status,
                       SUM ( CASE WHEN  transtype LIKE '%Receipt%'  THEN  transamount + matchamount ELSE  0  END)  AS YTD_Receipt,
                       SUM ( CASE WHEN  transtype LIKE '%Credit%'   THEN  transamount + matchamount ELSE  0  END)  AS YTD_CREDIT_Total,
                       min ( 
                       CASE WHEN  transtype LIKE '%Receipt%' or transtype like '%Credit%' or status = 'Lifetime'
                           THEN  (
                           CASE WHEN transdate <=  cast ('01/01/' + @CurrentYear AS DATE) or status = 'Lifetime' THEN  cast ('01/01/' + @CurrentYear AS DATE)
                              ELSE  transdate   
                              END)  ELSE null END
                       )   EnrollDate                      
                   FROM advcontact c 
                       inner join  dbo.advContactTransHeader h on c.contactid = h.contactid  
                       INNER JOIN dbo.advContactTransLineItems l  ON     h.transid = l.transid  AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear   OR (    h.TransYear = 'CAP' AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from  dbo.advAllocationLevels  alll WHERE MEMBID =@MEMBID AND TRANSYEAR = @CurrentYear
                           ) al  ON   l.ProgramID = al.ProgramID  AND al.TransYear = @CurrentYear INNER JOIN dbo.advprogram p ON p.programid = l.programid
                        where c.contactid in (select contactid from dbo.advContactTransHeader h 
                       INNER JOIN dbo.advContactTransLineItems l  ON     h.transid = l.transid  AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear   OR (    h.TransYear = 'CAP' AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from  dbo.advAllocationLevels  alll WHERE MEMBID =@MEMBID AND TRANSYEAR = @CurrentYear
                           ) al  ON   l.ProgramID = al.ProgramID  AND al.TransYear = @CurrentYear INNER JOIN dbo.advprogram p ON p.programid = l.programid 
                           union select contactid from advcontact where status = 'Lifetime')
                GROUP BY h.contactid, al.MembID, al.TransYear, c.status) YTD_ALL   ON c.ContactID = YTD_ALL.ContactID
               LEFT JOIN
               ( SELECT ml.membid, ml.levelid, ml.levelname, ml.minamount, isnull (min (ml2.minamount - .0001), 1000000000)  maxamount
                  FROM dbo.advMembershipLevels ml    LEFT JOIN dbo.advMembershipLevels ml2
                          ON     ml.membid = ml2.membid  AND ml2.minamount > ml.minamount  and ml2.membid  = @MEMBID
                    where ml.membid  = @MEMBID     GROUP BY ml.membid, ml.levelid,ml.levelname,ml.minamount) mbrl  ON     ytd_all.membid = mbrl.membid
                     AND ytd_all.YTD_Receipt +  ytd_all.YTD_Credit_Total BETWEEN mbrl.MinAmount AND mbrl.maxamount
                  )
       AS t
 WHERE 
status not in ('No Benefits') -- and donortype not like '%New Grad%'
and (
  ((YTD_Receipt + YTD_Credit_Total >= 25 or status = 'Lifetime') and (year(enrolldate) = @CurrentYearDT )) 
  or status = 'Lifetime')
group by  case when levelname is null then 'Lifetime' else levelname end,  minamount,  maxamount
order by minamount

---NewGrad
delete from  rpt_execdash_NewGrad_MembershipCounts_tb where Year = @CurrentYear 
insert  into rpt_execdash_NewGrad_MembershipCounts_tb
SELECT  @CurrentYear Year,
  case when levelname is null then 'Lifetime' else levelname end levelname,  minamount,  maxamount, 
  count(distinct adnumber) YTD_cnt,
  getdate() update_date 
  FROM (SELECT c.contactid,  c.adnumber, c.firstname, c.lastname, c.email, c.SetupDate, ytd_all.status, c.udf2 DonorType,
               ytd_all.YTD_Receipt,  ytd_all.YTD_Credit_Total, 
               ytd_all.YTD_Receipt  + ytd_all.YTD_Credit_Total   YTD_ALL,
               EnrollDate,  mbrl.levelname,    mbrl.minamount,  mbrl.maxamount
          FROM advcontact c  JOIN
               (SELECT h.contactid,  al.MembID,  al.TransYear, c.status,
                       SUM ( CASE WHEN  transtype LIKE '%Receipt%'  THEN  transamount + matchamount ELSE  0  END)  AS YTD_Receipt,
                       SUM ( CASE WHEN  transtype LIKE '%Credit%'   THEN  transamount + matchamount ELSE  0  END)  AS YTD_CREDIT_Total,
                       min ( 
                       CASE WHEN  transtype LIKE '%Receipt%' or transtype like '%Credit%' or status = 'Lifetime'
                           THEN  (
                           CASE WHEN transdate <=  cast ('01/01/' + @CurrentYear AS DATE) or status = 'Lifetime' THEN  cast ('01/01/' + @CurrentYear AS DATE)
                              ELSE  transdate   
                              END)  ELSE null END
                       )   EnrollDate                      
                   FROM advcontact c 
                       inner join  dbo.advContactTransHeader h on c.contactid = h.contactid  
                       INNER JOIN dbo.advContactTransLineItems l  ON     h.transid = l.transid  AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear   OR (    h.TransYear = 'CAP' AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from  dbo.advAllocationLevels  alll WHERE MEMBID =@MEMBID AND TRANSYEAR = @CurrentYear
                           ) al  ON   l.ProgramID = al.ProgramID  AND al.TransYear = @CurrentYear INNER JOIN dbo.advprogram p ON p.programid = l.programid
                        where c.contactid in (select contactid from dbo.advContactTransHeader h 
                       INNER JOIN dbo.advContactTransLineItems l  ON     h.transid = l.transid  AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear   OR (    h.TransYear = 'CAP' AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from  dbo.advAllocationLevels  alll WHERE MEMBID =@MEMBID AND TRANSYEAR = @CurrentYear
                           ) al  ON   l.ProgramID = al.ProgramID  AND al.TransYear = @CurrentYear INNER JOIN dbo.advprogram p ON p.programid = l.programid 
                           union select contactid from advcontact where status = 'Lifetime')
                GROUP BY h.contactid, al.MembID, al.TransYear, c.status) YTD_ALL   ON c.ContactID = YTD_ALL.ContactID
               LEFT JOIN
               ( SELECT ml.membid, ml.levelid, ml.levelname, ml.minamount, isnull (min (ml2.minamount - .0001), 1000000000)  maxamount
                  FROM dbo.advMembershipLevels ml    LEFT JOIN dbo.advMembershipLevels ml2
                          ON     ml.membid = ml2.membid  AND ml2.minamount > ml.minamount  and ml2.membid  = @MEMBID
                    where ml.membid  = @MEMBID     GROUP BY ml.membid, ml.levelid,ml.levelname,ml.minamount) mbrl  ON     ytd_all.membid = mbrl.membid
                     AND ytd_all.YTD_Receipt +  ytd_all.YTD_Credit_Total BETWEEN mbrl.MinAmount AND mbrl.maxamount
                  )
       AS t
 WHERE 
status not in ('No Benefits')   and donortype like '%New Grad%'
and (
  ((YTD_Receipt + YTD_Credit_Total >= 25 or status = 'Lifetime') and (year(enrolldate) = @CurrentYearDT )) 
  or status = 'Lifetime')
group by  case when levelname is null then 'Lifetime' else levelname end,  minamount,  maxamount
order by minamount

---Student
delete from  rpt_execdash_Student_MembershipCounts_tb where Year = @CurrentYear 
insert  into rpt_execdash_Student_MembershipCounts_tb
SELECT  @CurrentYear Year,
  case when levelname is null then 'Lifetime' else levelname end levelname,  minamount,  maxamount, 
  count(distinct adnumber) YTD_cnt,
  getdate() update_date 
  FROM (SELECT c.contactid,  c.adnumber, c.firstname, c.lastname, c.email, c.SetupDate, ytd_all.status, c.udf2 DonorType,
               ytd_all.YTD_Receipt,  ytd_all.YTD_Credit_Total, 
               ytd_all.YTD_Receipt  + ytd_all.YTD_Credit_Total   YTD_ALL,
               EnrollDate,  mbrl.levelname,    mbrl.minamount,  mbrl.maxamount
          FROM advcontact c  JOIN
               (SELECT h.contactid,  al.MembID,  al.TransYear, c.status,
                       SUM ( CASE WHEN  transtype LIKE '%Receipt%'  THEN  transamount + matchamount ELSE  0  END)  AS YTD_Receipt,
                       SUM ( CASE WHEN  transtype LIKE '%Credit%'   THEN  transamount + matchamount ELSE  0  END)  AS YTD_CREDIT_Total,
                       min ( 
                       CASE WHEN  transtype LIKE '%Receipt%' or transtype like '%Credit%' or status = 'Lifetime'
                           THEN  (
                           CASE WHEN transdate <=  cast ('01/01/' + @CurrentYear AS DATE) or status = 'Lifetime' THEN  cast ('01/01/' + @CurrentYear AS DATE)
                              ELSE  transdate   
                              END)  ELSE null END
                       )   EnrollDate                      
                   FROM advcontact c 
                       inner join  dbo.advContactTransHeader h on c.contactid = h.contactid  
                       INNER JOIN dbo.advContactTransLineItems l  ON     h.transid = l.transid  AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear   OR (    h.TransYear = 'CAP' AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from  dbo.advAllocationLevels  alll WHERE MEMBID =@StudentMEMBID AND TRANSYEAR = @CurrentYear
                           ) al  ON   l.ProgramID = al.ProgramID  AND al.TransYear = @CurrentYear INNER JOIN dbo.advprogram p ON p.programid = l.programid
                        where c.contactid in (select contactid from dbo.advContactTransHeader h 
                       INNER JOIN dbo.advContactTransLineItems l  ON     h.transid = l.transid  AND (matchinggift = 0 OR matchinggift IS NULL)
                             AND (   h.TransYear =@CurrentYear   OR (    h.TransYear = 'CAP' AND transdate >=cast ('01/01/' + @CurrentYear AS DATE)))
                       INNER JOIN (select alll.programid, alll.membid , alll.transyear from  dbo.advAllocationLevels  alll WHERE MEMBID =@StudentMEMBID AND TRANSYEAR = @CurrentYear
                           ) al  ON   l.ProgramID = al.ProgramID  AND al.TransYear = @CurrentYear INNER JOIN dbo.advprogram p ON p.programid = l.programid 
                           union select contactid from advcontact where status = 'Lifetime')
                GROUP BY h.contactid, al.MembID, al.TransYear, c.status) YTD_ALL   ON c.ContactID = YTD_ALL.ContactID
               LEFT JOIN
               ( SELECT ml.membid, ml.levelid, ml.levelname, ml.minamount, isnull (min (ml2.minamount - .0001), 1000000000)  maxamount
                  FROM dbo.advMembershipLevels ml    LEFT JOIN dbo.advMembershipLevels ml2
                          ON     ml.membid = ml2.membid  AND ml2.minamount > ml.minamount  and ml2.membid  = @StudentMEMBID
                    where ml.membid  = @StudentMEMBID     GROUP BY ml.membid, ml.levelid,ml.levelname,ml.minamount) mbrl  ON     ytd_all.membid = mbrl.membid
                     AND ytd_all.YTD_Receipt +  ytd_all.YTD_Credit_Total BETWEEN mbrl.MinAmount AND mbrl.maxamount
                  )
       AS t
 WHERE 
status not in ('No Benefits')  
and (
  ((YTD_Receipt +  YTD_Credit_Total >= 15 or status = 'Lifetime') and (year(enrolldate) = @CurrentYearDT )) 
  or status = 'Lifetime')
group by  case when levelname is null then 'Lifetime' else levelname end,  minamount,  maxamount
order by minamount


              FETCH NEXT FROM TixCursor
              INTO @CurrentYearDT 
              
         end
         
    CLOSE tixCursor      
   end
GO
