SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_DonorSummaryLimited null, null,  null,null,  null, null,  null, null, null,  null, null,  1
--drop  procedure [amy].[rpt_DonorSummaryLimited]
CREATE procedure [amy].[rpt_DonorSummaryLimited] (
@TRANSTYPE varchar(20)  =  'TRANSYEAR',
@TRANSYEAR nvarchar(40) = null , -- '2015' , --cast(year(getdate()) as varchar), 
 @TRANSSTART date = null, 
 @TRANSEND date = null, 
 @PPSNAPSHOT bit = null, 
 @ENTRYDATE varchar(50)=null, --'01/15/2015', 
 @LINKEDACCOUNTS  bit = null, 
 @GROUPS bit =null, 
 @ADDRESS bit = null, 
 @TRANSDETAIL bit = null, 
 @TRANSSUM  bit = null, 
 @STATUS bit = 1)
as 

declare @querysql varchar(MAX)

set @querysql = 'select  c.adnumber, c.contactid,
c.AccountName ,
c.firstname,
c.lastname, c.email ,
cei.PrefClassYear "Alumni", lifetimegiving, c.adjustedpp, c.PPRank,
c.status, c.udf2 DonorType, 
c.PHHome, 
c.PHBusiness, 
c.PHOther1,
c.staffassigned,
c.udf4 "MajorGiftsName",
c.udf1 "MajotGiftsStatus", 
c.UDF5 "MailingName", '

if  @PPSNAPSHOT = 1
set @querysql = @querysql + ' PPSNAP.cash_basis_ppts+ PPSNAP.linked_ppts- PPSNAP.linked_ppts_given_up "PP Snapshot", PPSNAP.Rank "Rank Snapshot", '
else set @querysql = @querysql +  'null     "PP Snapshot", null "Rank Snapshot", '

if  @GROUPS = 1
set @querysql = @querysql + '
"Athletic Ambassadors",
 "Champions Council",
 "Diamond Champions Council",
 "MVP",
"Eppright",
"Board of Trustees",
 "Lettermen", 
 "Endowed",
 "Faculty/Staff", '
 else 
 set @querysql = @querysql + '
null "Athletic Ambassadors",
null  "Champions Council",
null  "Diamond Champions Council",
null  "MVP",
null "Eppright",
null "Board of Trustees",
null  "Lettermen", 
null  "Endowed",
null  "Faculty/Staff", '

 if  @ADDRESS = 1
set @querysql = @querysql + ' ca.Salutation, ca.Address1, ca.Address2, ca.Address3, ca.City , ca.State , ca.zip , '
else 
set @querysql = @querysql + '
null Salutation,
null Address1, 
null Address2, 
null Address3, 
null City , 
null State ,
null zip , '
-- Allocation Detail

if @TRANSDETAIL = 1
set @querysql = @querysql + ' "Allocation", pledge_trans_amount, receipt_trans_amount, pledge_match_amount, receipt_match_amount, credit_amount, matchinggift  , '
  else 
 set @querysql = @querysql + 'null "Allocation", 
  null pledge_trans_amount,   
  null receipt_trans_amount,   
  null pledge_match_amount,   
  null receipt_match_amount, 
  null credit_amount,
  null matchinggift  , ' 
  
  if @TRANSSUM = 1
set @querysql = @querysql + '    tsum.totalpledge,     tsum.totalreceipt,  tsum.totalcredit ,  '
else 
set @querysql = @querysql + '   null totalpledge,    null totalreceipt,  null totalcredit ,  '

set @querysql = @querysql + ' '+ @transyear + ' Yearrun ,'  +
' ''' + cast( @TRANSSTART as varchar ) + ''' transstart, ' +
' ''' + cast( @TRANSEND as varchar ) + ''' transend, '  +
 cast( @PPSNAPSHOT as varchar ) + ' ppsnapshot, '  +
' ''' +cast( @ENTRYDATE as varchar ) + ''' entrydate, '  +
 cast( @LINKEDACCOUNTS as varchar ) + ' linkedaccount, ' +
 cast( @GROUPS as varchar ) + ' groups, ' +
 cast( @ADDRESS as varchar ) + ' address, ' +
 cast( @TRANSDETAIL as varchar ) + ' transdetail, ' +
 cast( @TRANSSUM as varchar ) + ' transsum, ' +
cast(  @STATUS as varchar ) + ' status2, '  

set @querysql = @querysql + ' 1 rttest1 '  

 set @querysql = @querysql  + ' from advcontact c left join advqaContactExtendedInfo cei on cei.contactid = c.contactid '

if  @PPSNAPSHOT = 1
set @querysql = @querysql  + 'left join advHistoricalPriorityPoints  PPSnap  on (c.contactid =ppsnap.contactid and  entrydate =''' + @ENTRYDATE + ''' )'
         
 if  @ADDRESS = 1
  set @querysql = @querysql  + ' left join amy.advcontactaddresses_unique_primary_vw ca on (c.ContactID = ca.ContactID) '

if @GROUPS =1
  set @querysql = @querysql  + ' left join (select contactid,Max(case when groupid = 2 then ''X'' else null end) "Athletic Ambassadors",
Max(case when groupid = 1 then ''X'' else null end) "Champions Council",
Max(case when groupid = 3 then ''X'' else null end) "Diamond Champions Council",
Max(case when groupid = 7 then ''X'' else null end) "MVP",
Max(case when groupid = 4 then ''X'' else null end) "Eppright",
Max(case when groupid = 5 then ''X'' else null end) "Board of Trustees",
Max(case when groupid = 8 then ''X'' else null end) "Lettermen", 
Max(case when groupid = 9 then ''X'' else null end) "Endowed",
Max(case when groupid = 10 then ''X'' else null end) "Faculty/Staff"
from advqaDonorGroupbyYear dg where  memberyear in (' + @transyear   + ') group by contactid ) mem on mem.contactid = c.contactid '


if @TRANSDETAIL = 1
  set @querysql = @querysql  + ' left join (
SELECT   h1.contactid ,p.programname "Allocation", 
  sum (CASE WHEN transtype LIKE ''%Pledge%'' THEN  l.TransAmount ELSE  0 END)  pledge_trans_amount,   
  sum (CASE WHEN transtype LIKE ''%Receipt%'' THEN l.TransAmount ELSE  0 END)  receipt_trans_amount,   
  sum (CASE WHEN transtype LIKE ''%Pledge%'' THEN  l.MatchAmount ELSE 0 END)  pledge_match_amount,   
  sum (CASE WHEN transtype LIKE ''%Receipt%'' THEN l.matchamount ELSE    0   END) receipt_match_amount, 
  sum (CASE WHEN transtype LIKE ''%Credit%'' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  credit_amount,
  matchinggift  from  advcontacttransheader h1,  advcontacttranslineitems l,  advProgram p
where  h1.TransID = l.TransID AND p.ProgramID = l.ProgramID '

if @TRANSDETAIL = 1 and @TRANSTYPE = 'TRANSYEAR'
  set @querysql = @querysql  + ' and transyear in (' + @transyear   + ') '

if @TRANSDETAIL = 1 and @TRANSTYPE = 'TRANSDATE'
  set @querysql = @querysql  + ' and  transdate between ''' + cast( @TRANSSTART as varchar) + ''' and ''' + cast( @TRANSEND as varchar)  + ''' '

if @TRANSDETAIL = 1 and @TRANSTYPE not in ( 'TRANSDATE','TRANSYEAR')
 set @querysql = @querysql  + ' and 1=2 '
 
if @TRANSDETAIL = 1
 set @querysql = @querysql  + ' group by h1.contactid ,p.programname,  matchinggift  ) detail on detail.contactid = c.contactid '
 
 
 if @TRANSSUM = 1
  set @querysql = @querysql  + ' left join  (SELECT   h1.contactid ,
  sum (CASE WHEN transtype LIKE ''%Pledge%'' THEN  l.TransAmount +l.MatchAmount ELSE  0 END)  totalpledge,   
  sum (CASE WHEN transtype LIKE ''%Receipt%'' THEN l.TransAmount +l.MatchAmount ELSE  0 END)  totalreceipt,
  sum (CASE WHEN transtype LIKE ''%Credit%'' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  totalcredit
  from  advcontacttransheader h1, advcontacttranslineitems l,  advProgram p
where  h1.TransID = l.TransID AND p.ProgramID = l.ProgramID '

if @TRANSSUM =1  and @TRANSTYPE = 'TRANSYEAR' 
  set @querysql = @querysql  + ' and transyear in (' + @transyear   + ') '

if @TRANSSUM = 1 and @TRANSTYPE = 'TRANSDATE'
  set @querysql = @querysql  + ' and  transdate between ''' + cast( @TRANSSTART as varchar) + ''' and ''' + cast( @TRANSEND as varchar)  + ''' '

 if @TRANSSUM = 1
  set @querysql = @querysql  + ' group by h1.contactid   ) tsum on tsum.contactid = c.contactid '
  
 
 if @STATUS = 1
 set @querysql = @querysql  + ' where (( status in (''Active'',''Lifetime'')))'
 
 

--select @querysql
execute( @querysql)
--EXECUTE sp_executesql @SQLQuery, @ParameterDefinition, @EmpID
GO
