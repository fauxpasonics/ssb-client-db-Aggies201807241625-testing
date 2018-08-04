SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_DonorLettermenTransactionReport '01/01/2018','03/01/2018'


CREATE PROCEDURE [amy].[rpt_DonorLettermenTransactionReport] (@startdate date = '01/01/2015', @enddate date = '12/31/2015')

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @CurrentYearDT int
Declare @yearstartdate date
Declare @modenddate datetime
DECLARE @MEMBID INT

SET @CurrentYear   = cast( year (@startdate) as varchar);
SET @CurrentYearDT = year (@startdate) ;
Set @yearstartdate = cast ('01/01/' + @CurrentYear AS DATE);
set  @modenddate  =   CONVERT(DATETIME, CONVERT(varchar(11),@enddate, 111 ) + ' 23:59:59', 111)



  select    accountname "Account Name", t.adnumber "AD Number", transdate "Transaction Date", transamount "Transaction Amount", 
   t.alumniinfo "Alumni Information", programname "Allocation", 
   Address1 "Address Line 1",Address2 "Address Line 2", Address3 "Address Line 3" ,City ,State ,Zip "Zip Code", null County, email "Email Address"
   ,transyear, matchamount,
(select value from amy.donorcategory_vw cdc where categorycode = 'SPORT' and cdc.adnumber = t.adnumber )   Sport , 
   PaymentType  
from (
select  driveyear transyear, c.contactid, c.adnumber, c.accountname, c.firstname, c.lastname, c.status, c.donortype donortype, 
c.LifetimeGiving, c.AdjustedPP, case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank, 
c.UDF4, c.Email,
c.homephone PHHome, c.busphone PHBusiness, c.cellphone PHOther1,  null PHOther2, 'Cell' PHOther1Desc,  null PHOther2Desc,
allocationname programname, ReceivedDate transdate, PaymentAmt transamount, MatchingPaymentAmt matchamount, c.classyear AlumniInfo,  null PaymentType,
 adj_address1  Address1 , adj_address2 Address2 , adj_address3 Address3  ,City ,State ,Zip 
  FROM amy.PacTranItem_alt_vw a , amy.PatronExtendedInfo_vw c
         WHERE     a.acct = c.patron and 
 (driveyear IN (@currentyear,0)  and
ReceivedDate between @startdate and @modenddate)
and ( allocationname like '%Lettermen%')
) t where abs( transamount) + abs(matchamount)  <> 0 
--left join dataqa..ContactExtendedInfo ce on t.contactid = ce.contactid
order by transdate

/*
  select    accountname "Account Name", t.adnumber "AD Number", transdate "Transaction Date", transamount "Transaction Amount", 
   t.alumniinfo "Alumni Information", programname "Allocation", 
   Address1 "Address Line 1",Address2 "Address Line 2", Address3 "Address Line 3" ,City ,State ,Zip "Zip Code", County, email "Email Address"
   ,transyear, matchamount,
   (select value from advcontactDonorCategories cdc where categoryid = 358 and cdc.contactid = t.contactid) Sport , 
   PaymentType  
from (
select  transyear, c.contactid, c.adnumber, c.accountname, c.firstname, c.lastname, c.status, c.udf2 donortype, 
c.LifetimeGiving, c.AdjustedPP, case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank, 
c.UDF4, c.Email,
c.PHHome, c.PHBusiness, c.PHOther1, c.PHOther2, c.PHOther1Desc, c.PHOther2Desc,
p.programname, transdate,l.transamount, l.matchamount, c.AlumniInfo, h.PaymentType
  FROM advcontact c,advcontacttransheader h,advcontacttranslineitems l,advProgram p
         WHERE     c.contactid = h.contactid
AND h.TransID = l.TransID
AND p.ProgramID = l.ProgramID
AND (transyear IN (:currentyear,'CAP')  and
transdate between :startdate and :enddate)
and (matchinggift = 0 or matchinggift is null)
and transtype like '%Receipt%'
and (  p.programname like '%Lettermen%')
) t 
left join amy.advcontactaddresses_unique_primary_vw ca on t.contactid= ca.contactid
--left join dataqa..ContactExtendedInfo ce on t.contactid = ce.contactid
order by transdate*/
GO
