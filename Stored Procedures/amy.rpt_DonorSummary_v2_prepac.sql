SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_DonorSummary_v2
CREATE procedure [amy].[rpt_DonorSummary_v2_prepac] (
@transtype nvarchar(50) = 'START',
@TRANSYEAR nvarchar(50) = null , -- '2015' , --cast(year(getdate()) as varchar), 
 @TRANSSTART date = null, 
 @TRANSEND date = null, 
 @PPSNAPSHOT bit = 0, 
 @ENTRYDATE varchar(50)=null, --'01/15/2015', 
 @LINKEDACCOUNTS  bit = 0, 
 @GROUPS bit =0, 
 @ADDRESS bit = 0, 
 @TRANSDETAIL bit = 0, 
 @TRANSSUM  bit = 0, 
 @STATUS bit = 0,
 @ALLOCATIONS nvarchar(MAX) = null,
 @STAFFASSIGNED nvarchar(MAX) = null,
 @DONORGROUP nvarchar(MAX)= null, 
 @DONORCAT nvarchar(MAX)= null, 
 @LGSTART money= null, 
 @LGEND money= null, 
 @PSTART money= null, 
 @PEND money= null, 
 @RSTART money= null, 
 @REND money= null ,
 @REMOVEMATCHGIFT bit = 1,
 @ALLOCGROUP nvarchar(MAX) = null,
 @ADNUMBERLIST nvarchar(MAX) = null)
as 

declare @querysql nvarchar(MAX)
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)

 Set @ADNUMBERLISTCLEAN  =  replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),'')

if  @LGSTART is not null and @LGEND is null 
  set  @LGEND= 9999999999
if  @LGSTART is null and @LGEND is not null   
   set  @LGSTART= -999999999
 
if  @PSTART is not null and (@PEND is null   or @PEND = '')
  set  @PEND= 9999999999
if  (@PSTART is null  or @PSTART = '') and @PEND is not null 
  set  @PSTART= -999999999
 
if  @RSTART is not null and @REND is null 
  set  @REND= 9999999999
if  @RSTART is null and @REND is not null  
  set  @RSTART= -999999999

if @TRANSYEAR is null and @TRANSSTART is null and @TRANSEND is null and 
( ( @ALLOCGROUP is not null or  @ALLOCATIONS is not null )
  or @PSTART is not null
  or @RSTART is not null)
   begin
     set @TRANSSTART ='01/01/1900'
     set @TRANSEND ='12/31/9999'
   end
   
   
 if @TRANSEND is not null and @TRANSSTART is  null 
     set @TRANSSTART ='01/01/1900'
 
if @TRANSSTART is not null and @TRANSEND is  null 
     set @TRANSEND ='12/31/9999'


set @querysql = 'select  c.adnumber, c.contactid,
c.AccountName ,
c.firstname,
c.lastname, c.email ,
cei.PrefClassYear "Alumni", lifetimegiving, c.adjustedpp, c.PPRank,
c.status, c.udf2 DonorType, 
c.PHHome, 
c.PHBusiness, 
Mobile PHOther1,
c.staffassigned,
c.udf4 "MajorGiftsName",
c.udf1 "MajotGiftsStatus", 
c.UDF5 "MailingName", '
set @querysql = @querysql + ' (select [Value] from advContactDonorCategories d1 where categoryid = 360 and d1.contactid = c.contactid) "CCOffYear", '
set @querysql = @querysql + ' (select [Value] from advContactDonorCategories d1 where categoryid = 430 and d1.contactid = c.contactid) "SAHistory", '
if  isnull(@PPSNAPSHOT ,0)= 1
set @querysql = @querysql + ' isnull(PPSNAP.cash_basis_ppts, 0) + isnull(PPSNAP.linked_ppts, 0) - isnull(PPSNAP.linked_ppts_given_up, 0) "PP Snapshot", isnull(PPSNAP.Rank,999999) "Rank Snapshot", '
else set @querysql = @querysql +  'null     "PP Snapshot", null "Rank Snapshot", '

if  isnull(@GROUPS,0) = 1
set @querysql = @querysql + '
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 2 and  d1.contactid = c.contactid) "Athletic Ambassadors",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 1 and  d1.contactid = c.contactid) "Champions Council",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 3 and  d1.contactid = c.contactid) "Diamond Champions Council",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 7 and  d1.contactid = c.contactid) "MVP",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 4 and  d1.contactid = c.contactid) "Eppright",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 5 and  d1.contactid = c.contactid) "Board of Trustees",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 8 and  d1.contactid = c.contactid) "Lettermen", 
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 9 and  d1.contactid = c.contactid) "Endowed",
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 10 and  d1.contactid = c.contactid)"Faculty/Staff", 
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 11 and  d1.contactid = c.contactid) "JDC", 
(select distinct ''X'' from advqaDonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 12 and  d1.contactid = c.contactid) "1922Fund", '
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
null  "Faculty/Staff",
null  "JDC", 
null  "1922Fund",'

 if  isnull(@ADDRESS,0) = 1
set @querysql = @querysql + ' ca.Salutation, ca.Address1, ca.Address2, ca.Address3, ca.City , ca.State , ca.zip , '
else 
set @querysql = @querysql + '
null Salutation, null Address1,  null Address2,  null Address3,  null City , null State , null zip , ' 
-- Allocation Detail

if isnull(@TRANSDETAIL,0) = 1
set @querysql = @querysql + ' Allocation, '
else
set @querysql = @querysql + ' null Allocation, '

if ((@TRANSSTART is not null and @TRANSEND is not null) or @TRANSYEAR is not null)
set @querysql = @querysql +' pledge_trans_amount, receipt_trans_amount, pledge_match_amount, receipt_match_amount, credit_amount, matchinggift  , '
  else 
 set @querysql = @querysql + ' null pledge_trans_amount,  null receipt_trans_amount, null pledge_match_amount, null receipt_match_amount, null credit_amount, null matchinggift  , ' 
  
  if isnull(@TRANSSUM,0) = 1
set @querysql = @querysql + ' tsum.totalpledge, tsum.totalreceipt, tsum.totalcredit , '
else 
set @querysql = @querysql + ' null totalpledge, null totalreceipt, null totalcredit , '

set @querysql = @querysql + ' '+ isnull(@transyear,'null') + ' Yearrun ,' +
' ''' + isnull(cast( @TRANSSTART as varchar ),'null') + ''' transstart, ' +
' ''' + isnull(cast( @TRANSEND as varchar ),'null') + ''' transend, '  +
isnull( cast( @PPSNAPSHOT as varchar ),'null') + ' ppsnapshot, '  +
' ''' +isnull(cast( @ENTRYDATE as varchar ),'null') + ''' entrydate, '  +
isnull( cast( @LINKEDACCOUNTS as varchar ),'null') + ' linkedaccount, ' +
isnull( cast( @GROUPS as varchar ),'null') + ' groups, ' +
isnull( cast( @ADDRESS as varchar ),'null') + ' address, ' +
isnull( cast( @TRANSDETAIL as varchar ),'null') + ' transdetail, ' +
isnull( cast( @TRANSSUM as varchar ),'null') + ' transsum, ' +
isnull(cast(  @STATUS as varchar ),'null') + ' status2, '  

set @querysql = @querysql + ' [P2G Score Combo] P2GScoreCombo, [P2G Description] P2GDescription, [Net Worth] NetWorth, [Gift Capacity Range] GiftCapacityRange, c.Mobile, '  
set @querysql = @querysql + ' 1 rttest1 '  

 set @querysql = @querysql  + ' from advcontact c left join advqaContactExtendedInfo cei on (cei.contactid = c.contactid ) '
 set @querysql = @querysql  + ' left join  amy.wealthengine we  on (we.originalid = c.adnumber) '
 
 if  isnull(@ADDRESS ,0)= 1
  set @querysql = @querysql  + ' left join amy.advcontactaddresses_unique_primary_vw   ca on (c.ContactID = ca.ContactID) '
  
if  isnull(@PPSNAPSHOT,0) =1 
set @querysql = @querysql  + ' left join advHistoricalPriorityPoints  PPSnap on (c.contactid = ppsnap.contactid and entrydate = ''' + isnull(@ENTRYDATE,'') + ''' ) '
         
/*
if isnull(@GROUPS,0) =1 
  set @querysql = @querysql  + ' left join (select contactid, max(case when groupid = 2 then 1 else null end) "Athletic Ambassadors",
 max(case when groupid = 1 then 1 else null end) "Champions Council",
 Max(case when groupid = 3 then 1 else null end) "Diamond Champions Council",
 Max(case when groupid = 7 then 1 else null end) "MVP",
 Max(case when groupid = 4 then 1 else null end) "Eppright",
 Max(case when groupid = 5 then 1 else null end) "Board of Trustees",
 Max(case when groupid = 8 then 1 else null end) "Lettermen", 
 Max(case when groupid = 9 then 1 else null end) "Endowed",
 Max(case when groupid = 10 then 1 else null end) "Faculty/Staff"
 from advqaDonorGroupbyYear dg group by contactid ) mem on mem.contactid = c.contactid '
--from advqaDonorGroupbyYear dg where  dg.memberyear  = '''+ cast(year(getdate()) as varchar)+ '''  group by contactid ) mem on mem.contactid = c.contactid '
*/

if   ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
  set @querysql = @querysql  + '  join ( SELECT   h1.contactid , '
  
if (isnull(@TRANSDETAIL,0) = 1 ) and  ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
  set @querysql = @querysql  +  'p.programname Allocation, '

 if  ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
  set @querysql = @querysql  + '  sum (CASE WHEN transtype LIKE ''%Pledge%'' THEN  l.TransAmount ELSE  0 END)  pledge_trans_amount,   
  sum (CASE WHEN transtype LIKE ''%Receipt%'' THEN l.TransAmount ELSE  0 END)  receipt_trans_amount,   
  sum (CASE WHEN transtype LIKE ''%Pledge%'' THEN  l.MatchAmount ELSE 0 END)  pledge_match_amount,   
  sum (CASE WHEN transtype LIKE ''%Receipt%'' THEN l.matchamount ELSE    0   END) receipt_match_amount, 
  sum (CASE WHEN transtype LIKE ''%Credit%'' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  credit_amount,
  case when matchinggift = 1 then ''X'' else null end matchinggift from  advcontacttransheader h1,  advcontacttranslineitems l,  advProgram p
where  h1.TransID = l.TransID AND p.ProgramID = l.ProgramID '

 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and  (isnull(@ALLOCATIONS , '0') <> '0' or isnull(@ALLOCGROUP , '0') <> '0')
  set @querysql = @querysql  +  '  and  '
  
 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0' and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' ( '
  
 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0'
  set @querysql = @querysql  +  '  p.programid in (' +@ALLOCATIONS + ') '
     
     if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0' and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' or '
  
  
  
   if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  '  p.programid in ( select programid from [amy].[vw_CategoryAllocationList] where categoryid in (' +@ALLOCGROUP + ')) '
  
   if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0' and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' ) '
  

if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null) and  (@transyear is not null)
  set @querysql = @querysql  + ' and transyear in (' + @transyear   + ') '

if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null) and  (@TRANSSTART is not null and @TRANSEND is not null) 
  set @querysql = @querysql  + ' and  transdate between ''' + cast( @TRANSSTART as varchar) + ''' and ''' + cast( @TRANSEND as varchar)  + ''' '

--if  ((@TRANSSTART is  null or @TRANSEND is  null) and @transyear is  null)
-- set @querysql = @querysql  + ' and 1=2 '

if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and (@REMOVEMATCHGIFT  = 1 )
  set @querysql = @querysql  + ' and ( MatchingGift =0 or MatchingGift  is null) '
 
if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
 set @querysql = @querysql  + ' group by h1.contactid , '

if isnull(@TRANSDETAIL,0) = 1 and ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
 set @querysql = @querysql  + ' p.programname, '
 
 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
 set @querysql = @querysql  + ' case when MatchingGift = 1 then ''X'' else null end   ) detail on detail.contactid = c.contactid '
 
 /*
 if isnull(@TRANSSUM , 0)=1
  set @querysql = @querysql  + '  join  (SELECT   h1.contactid ,
  sum (CASE WHEN transtype LIKE ''%Pledge%'' THEN  l.TransAmount +l.MatchAmount ELSE  0 END)  totalpledge,   
  sum (CASE WHEN transtype LIKE ''%Receipt%'' THEN l.TransAmount +l.MatchAmount ELSE  0 END)  totalreceipt,
  sum (CASE WHEN transtype LIKE ''%Credit%'' THEN  l.TransAmount+ l.MatchAmount  ELSE  0   END)  totalcredit
  from  advcontacttransheader h1, advcontacttranslineitems l,  advProgram p
where  h1.TransID = l.TransID AND p.ProgramID = l.ProgramID '

 if  isnull(@TRANSSUM , 0)=1 and isnull(@ALLOCATIONS , 0) <> 0
  set @querysql = @querysql  +  ' and p.programid in (' +@ALLOCATIONS + ') '
  
if isnull(@TRANSSUM , 0)=1 and  (@transyear is not null)
  set @querysql = @querysql  + ' and transyear in (' + @transyear   + ') '

if isnull(@TRANSSUM , 0 )=1 and  (@TRANSSTART is not null and @TRANSEND is not null) 
  set @querysql = @querysql  + ' and  transdate between ''' + cast( @TRANSSTART as varchar) + ''' and ''' + cast( @TRANSEND as varchar)  + ''' '

if isnull(@TRANSSUM , 0) = 1 and  ((@TRANSSTART is  null or @TRANSEND is  null) and @transyear is  null)
 set @querysql = @querysql  + ' and 1=2 '
 
 if isnull(@TRANSSUM , 0)= 1
  set @querysql = @querysql  + ' group by h1.contactid   ) tsum on tsum.contactid = c.contactid ' 
  */
  
   -- if isnull( @STATUS, 0) =1 or (@STAFFASSIGNED is not null and @STAFFASSIGNED <> '') OR  ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
  set @querysql = @querysql  + ' where 1=1'
  
   if (isnull(@TRANSTYPE, '') ='START')
 set @querysql = @querysql  + 'and  1 =2 '

  
 if isnull( @STATUS, 0) = 1
 set @querysql = @querysql  + ' and (( status in (''Active'',''Lifetime''))) '
 
 if (@STAFFASSIGNED is not null and @STAFFASSIGNED <> '')
-- set @querysql = @querysql  +  ' and staffassigned = ''' +@STAFFASSIGNED + ''' '
-- set @querysql = @querysql  +  ' and staffassigned in  ( ' + @STAFFASSIGNED+ ' )  '
 set @querysql = @querysql  +  ' and  '','+ @STAFFASSIGNED +','' '+' like ' + '   ''%,'' +staffassigned+'',%'' '  
if isnull( @DONORGROUP, '') <> '' and  isnull( @DONORGROUP, '') <> '0'
set @querysql = @querysql  + ' and c.contactid in  (select contactid from  advqaDonorGroupbyYear  dg2  where  dg2.memberyear  =  cast(year(getdate()) as varchar) and dg2.groupid in ( ' + @DONORGROUP + ' ) ) '

if isnull( @DONORCAT, '') <> '' and  isnull( @DONORCAT, '') <> '0'
--set @querysql = @querysql  + ' and c.contactid in  (select contactid from  advContactDonorCategories  cdc where   cdc.categoryid in ( ' + cast(@DONORCAT as varchar) + ' ) ) '
 set @querysql = @querysql +' and c.contactid in  (select contactid from  advContactDonorCategories  cdc where  '','+ @DONORCAT +','' '+' like ' + '   ''%,'' +cast(cdc.categoryid as varchar)+'',%'' )'  
if isnull( @ADNUMBERLISTCLEAN , '') <> ''
set @querysql = @querysql  + ' and c.adnumber in  ( ' + @ADNUMBERLISTCLEAN + ' )  '


if isnull( cast(@LGSTART as varchar) , '') <> '' and isnull( cast(@LGEND as varchar) , '') <> ''
set @querysql = @querysql  + ' and lifetimegiving between  ' + cast(@LGSTART as varchar)  + ' and ' +cast(@LGEND as varchar)  + ' '

if isnull( cast(@PSTART as varchar) , '') <> '' or isnull( cast(@PEND as varchar) , '') <> ''
set @querysql = @querysql  + ' and (pledge_trans_amount + pledge_match_amount) between  ' + cast(@PSTART as varchar)  + ' and ' +cast(@PEND as varchar)  + ' '


if isnull( cast(@RSTART as varchar) , '') <> '' or isnull( cast(@REND as varchar) , '') <> ''
set @querysql = @querysql  + ' and (receipt_trans_amount + receipt_match_amount) between  ' + cast(@RSTART as varchar)  + ' and ' +cast(@REND as varchar)  + ' '

--select @querysql
execute( @querysql)
--EXECUTE sp_executesql @SQLQuery, @ParameterDefinition, @EmpID
GO
