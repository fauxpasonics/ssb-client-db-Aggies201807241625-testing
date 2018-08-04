SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_DonorSummary_v2] (
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
Declare @ALLOCATIONSVARCHAR  nvarchar(MAX)
Declare @ALLOCGROUPVARCHAR nvarchar(MAX)

 Set @ADNUMBERLISTCLEAN  =  '''' + replace(replace(REPLACE(REPLACE(REPLACE(@ADNUMBERLIST,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),''),',',''',''') + ''''
 Set  @ALLOCATIONSVARCHAR  =  '''' + replace(replace(REPLACE(REPLACE(REPLACE( @ALLOCATIONS ,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),''),',',''',''') + ''''
 Set  @ALLOCGROUPVARCHAR  =  '''' + replace(replace(REPLACE(REPLACE(REPLACE( @ALLOCGROUP,CHAR(10),''),CHAR(13),''),' ',''), CHAR(9),''),',',''',''') + ''''
 
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


set @querysql = 'select p.PATRON adnumber, null contactid,
p.mail_name  AccountName ,
case when charindex('','', P.[NAME] )  <> 0 then substring(P.[Name], charindex('','', P.[NAME] ) +1,50)  else null end firstname,
case when charindex('','', P.[NAME] )  <> 0 then substring(P.[Name], 1, charindex('','', P.[NAME] ) -1 )  else P.[Name] end  lastname, Email.PHONE email ,
(select UDFValue from ods.PAC_AccountUDF  where accountid =  p.PATRON  and udfdefinitionid = ''CLC1'' and udfTypecode = ''A'')  "Alumni",
d.LifetimeDonationAmt/100  lifetimegiving, d.CurrentPoints  adjustedpp, d.PointsRank PPRank,
stat.Name status,  dtype.Name  DonorType, 
home.phone PHHome, 
bus.phone PHBusiness, 
cell.phone PHOther1,
StaffAssigned staffassigned,
d.PublishName  "MajorGiftsName",
(select UDFValue from ods.PAC_AccountUDF  where accountid =  p.PATRON and udfdefinitionid= ''MGSTAT'' and udfTypecode = ''A'')  "MajotGiftsStatus", 
addr.MAIL_NAME "MailingName", '
set @querysql = @querysql + ' (select DonorCategoryValue from ods.PAC_DonorCategory where   DonorCategoryID  =''CCOFFYEAR'' and accountid = p.PATRON ) "CCOffYear", '
set @querysql = @querysql + ' (select DonorCategoryValue from ods.PAC_DonorCategory where   DonorCategoryID  =''SA_11012017'' and accountid = p.PATRON ) "SAHistory", '
if  isnull(@PPSNAPSHOT ,0)= 1
set @querysql = @querysql + ' isnull(PPSNAP.cash_basis_ppts, 0) + isnull(PPSNAP.linked_ppts, 0) - isnull(PPSNAP.linked_ppts_given_up, 0) "PP Snapshot", isnull(PPSNAP.Rank,999999) "Rank Snapshot", '
else set @querysql = @querysql +  'null     "PP Snapshot", null "Rank Snapshot", '

if  isnull(@GROUPS,0) = 1
set @querysql = @querysql + '
(select  distinct ''X''  from ods.PAC_DonorMembership where membershipid = ''AA'' and  DriveYear = year(getdate()) and accountid = p.PATRON) "Athletic Ambassadors",
(select  distinct ''X''  from ods.PAC_DonorMembership where membershipid = ''CC'' and  DriveYear = year(getdate()) and accountid = p.PATRON) "Champions Council",
(select distinct ''X'' from ods.PAC_DonorMembership where membershipid = ''CC'' and  DriveYear = year(getdate()) and  ReceiptedLevelName = ''Diamond'' and accountid = p.PATRON) "Diamond Champions Council",
(select distinct ''X'' from ods.PAC_DonorCategory where   DonorCategoryID  =''MVP'' and accountid = p.PATRON) "MVP",
(select distinct ''X'' from ods.PAC_DonorCategory where   DonorCategoryID  =''DD'' and accountid = p.PATRON) "Eppright",
(select distinct ''X'' from ods.PAC_DonorCategory where   DonorCategoryID  =''BOT'' and accountid = p.PATRON) "Board of Trustees",
(select distinct ''X'' from ods.PAC_DonorCategory where   DonorCategoryID  =''LM'' and accountid = p.PATRON) "Lettermen", 
(select distinct ''X'' from ods.PAC_DonorCategory where   DonorCategoryID   in (''EDWD2'',''EDWD4'',''EDWD6'') and accountid = p.PATRON) "Endowed",
(select distinct ''X'' from amy.DonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and  groupid = 10 and adnumber = p.PATRON)"Faculty/Staff", 
(select distinct ''X'' from ods.PAC_DonorCategory where   DonorCategoryID  =''JDC'' and accountid = p.PATRON) "JDC", 
(select distinct ''X'' from amy.DonorGroupbyYear d1 where memberyear =  '''+ cast(year(getdate()) as varchar)+ ''' and   groupid = 12 and adnumber = p.PATRON) "1922Fund", '
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
set @querysql = @querysql + ' sal.Salutation Salutation, case when addr3 is not null then addr.addr3 else addr.ADDR1  end Address1, sal.Salutation Salutation, case when addr3 is not null then addr.addr1 else addr.ADDR2 end  Address2, sal.Salutation Salutation, case when addr3 is not null then  addr.ADDR2 else null end  Address3,   substring(zip.CSZ, 1, charindex('','',zip.CSZ)-1) City , substring(zip.CSZ, charindex('', '',zip.CSZ)+2,2) State ,  addr.SYS_ZIP   zip , '
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

set @querysql = @querysql + ' [P2G Score Combo] P2GScoreCombo, [P2G Description] P2GDescription, [Net Worth] NetWorth, [Gift Capacity Range] GiftCapacityRange,cell.phone Mobile, '  
set @querysql = @querysql + ' 1 rttest1 '  

 set @querysql = @querysql  + ' from  dbo.pd_patron p
left join dbo.PD_PATRON_PHONE_TYPE Email on Email.PATRON = p.patron and email.phone_type = ''E''
left join dbo.PD_PATRON_PHONE_TYPE Home on home.PATRON = p.patron and home.phone_type = ''H''
left join dbo.PD_PATRON_PHONE_TYPE Bus on Bus.PATRON = p.patron and Bus.phone_type = ''B''
left join dbo.PD_PATRON_PHONE_TYPE cell on cell.PATRON = p.patron and cell.phone_type = ''C''
left join ods.PAC_Donor d on d.AccountID = p.patron 
left join dbo.pd_patron_sal_type sal on sal.patron = p.PATRON and sal.SAL_TYPE =  ''I''
left join ods.PAC_codelanguage stat on stat.codetype = d.donorstatuscodetype and stat.codesubtype = d.donorstatuscodesubtype and stat.code = d.DonorStatusCode
left join ods.PAC_codelanguage dtype on  dtype.codetype = d.donortypecodetype  and dtype.codesubtype =  d.donortypecodesubtype and dtype.code = d.DonorTypeCode
left join  dbo.PD_ADDRESS addr on addr.ADTYPE = ''P'' and addr.patron = p.PATRON 
left join dbo.SYS_ZIP zip on zip.sys_zip =  case when charindex(''-'',addr.SYS_ZIP) <> 0 then substring(addr.SYS_ZIP, 1,(charindex(''-'',addr.SYS_ZIP)-1)) else addr.SYS_ZIP end
left join (select accountid, LoginName StaffAssigned from ods.PAC_AccountGeneralRep ar,  dbo.PacUser pu where pu.clientid = ''TAM''  and ar.GeneralRepUserID = pu.PacUserID) SA on sa.accountid = p.patron
'
 set @querysql = @querysql  + ' left join  amy.wealthengine we  on (cast(we.originalid as varchar) = p.patron) '
 
 
 --if  isnull(@ADDRESS ,0)= 1
 -- set @querysql = @querysql  + ' left join  dbo.PD_ADDRESS addr on addr.ADTYPE = ''P'' and addr.patron = p.PATRON 
--left join dbo.SYS_ZIP zip on zip.sys_zip =  case when charindex(''-'',addr.SYS_ZIP) <> 0 then substring(addr.SYS_ZIP, 1,(charindex(''-'',addr.SYS_ZIP)-1)) else addr.SYS_ZIP end '
  
if  isnull(@PPSNAPSHOT,0) =1 
set @querysql = @querysql  + ' left join advHistoricalPriorityPoints  PPSnap on ( ppsnap.contactid = (select contactid from advcontact f where f.adnumber = p.patron) and entrydate = ''' + isnull(@ENTRYDATE,'') + ''' ) '
         
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
  set @querysql = @querysql  + '  join ( SELECT   acct, '
  
if (isnull(@TRANSDETAIL,0) = 1 ) and  ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
  set @querysql = @querysql  +  'l.Name Allocation, '

 if  ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
  set @querysql = @querysql  + '  sum (pledgeamt)  pledge_trans_amount,   
  sum (paymentamt)  receipt_trans_amount,   
  sum (Matchingpledgeamt)  pledge_match_amount,   
  sum (matchingpaymentamt) receipt_match_amount, 
  sum (creditamt)  credit_amount,
  null  matchinggift from allocationlanguage l, amy.PacTranItem_alt_vw a where languagecode = ''en_US''  and l.allocationid = a.allocationid '

 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and  (isnull(@ALLOCATIONS , '0') <> '0' or isnull(@ALLOCGROUP , '0') <> '0')
  set @querysql = @querysql  +  '  and  '
  
 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0' and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' ( '
  
 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0'
  set @querysql = @querysql  +  '  a.allocationid in (' +@ALLOCATIONSVARCHAR  + ') '
     
     if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0' and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' or '
  
  
  
   if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' a.allocationid  COLLATE DATABASE_DEFAULT in ( select programid from [amy].[vw_CategoryAllocationList] where categoryid in (' +@ALLOCGROUPVARCHAR + ')) '
  
   if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and isnull(@ALLOCATIONS , '0') <> '0' and isnull(@ALLOCGROUP , '0') <> '0'
  set @querysql = @querysql  +  ' ) '
  

if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null) and  (@transyear is not null)
  set @querysql = @querysql  + ' and driveyear in (' + @transyear   + ') '

if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null) and  (@TRANSSTART is not null and @TRANSEND is not null) 
  set @querysql = @querysql  + ' and  ReceivedDate between ''' + cast( @TRANSSTART as varchar) + ''' and ''' + cast( @TRANSEND as varchar)  + ''' '

--if  ((@TRANSSTART is  null or @TRANSEND is  null) and @transyear is  null)
-- set @querysql = @querysql  + ' and 1=2 '

--if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)  and (@REMOVEMATCHGIFT  = 1 )
--  set @querysql = @querysql  + ' and ( MatchingGift =0 or MatchingGift  is null) '
 
if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
 set @querysql = @querysql  + ' group by acct  '

if isnull(@TRANSDETAIL,0) = 1 and ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
 set @querysql = @querysql  + ', l.name '
 
 if ((@TRANSSTART is not null and @TRANSEND is not null) or @transyear is not null)
 set @querysql = @querysql  + '    ) detail on detail.acct = p.patron '
 
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
 set @querysql = @querysql  + ' and  1 =2 '

  
 if isnull( @STATUS, 0) = 1
 set @querysql = @querysql  + ' and ((d.DonorStatusCode in (''A'',''L''))) '
 
 if (@STAFFASSIGNED is not null and @STAFFASSIGNED <> '')
-- set @querysql = @querysql  +  ' and staffassigned = ''' +@STAFFASSIGNED + ''' '
-- set @querysql = @querysql  +  ' and staffassigned in  ( ' + @STAFFASSIGNED+ ' )  '
 set @querysql = @querysql  +  ' and  '','+ @STAFFASSIGNED +','' '+' like ' + '   ''%,'' +staffassigned+'',%'' '  
 
if isnull( @DONORGROUP, '') <> '' and  isnull( @DONORGROUP, '') <> '0'
set @querysql = @querysql  + ' and p.patron in  (select adnumber from   amy.DonorGroupbyYear  dg2  where  dg2.memberyear  =  cast(year(getdate()) as varchar) and dg2.groupid in ( ' + @DONORGROUP + ' ) ) '

if isnull( @DONORCAT, '') <> '' and  isnull( @DONORCAT, '') <> '0'
--set @querysql = @querysql  + ' and c.contactid in  (select contactid from  advContactDonorCategories  cdc where   cdc.categoryid in ( ' + cast(@DONORCAT as varchar) + ' ) ) '
 --set @querysql = @querysql +' and p.patron in  (select cast(c.adnumber as varchar) from  advcontact c, advContactDonorCategories  cdc where  c.contactid =cdc.contactid and '','+ @DONORCAT +','' '+' like ' + '   ''%,'' +cast(cdc.categoryid as varchar)+'',%'' )'  
 set @querysql = @querysql +' and p.patron in  (select accountid from  ods.pac_donorcategory  cdc where   '','+ @DONORCAT +','' '+' like ' + '   ''%,'' +donorcategoryid +'',%'' )'  
if isnull( @ADNUMBERLISTCLEAN , '') <> ''
set @querysql = @querysql  + ' and p.patron in  ( ' + @ADNUMBERLISTCLEAN + ' )  '


if isnull( cast(@LGSTART as varchar) , '') <> '' and isnull( cast(@LGEND as varchar) , '') <> ''
set @querysql = @querysql  + ' and d.LifetimeDonationAmt  between  ' + cast(@LGSTART as varchar)  + ' and ' +cast(@LGEND as varchar)  + ' '

if isnull( cast(@PSTART as varchar) , '') <> '' or isnull( cast(@PEND as varchar) , '') <> ''
set @querysql = @querysql  + ' and (pledge_trans_amount + pledge_match_amount) between  ' + cast(@PSTART as varchar)  + ' and ' +cast(@PEND as varchar)  + ' '


if isnull( cast(@RSTART as varchar) , '') <> '' or isnull( cast(@REND as varchar) , '') <> ''
set @querysql = @querysql  + ' and (receipt_trans_amount + receipt_match_amount) between  ' + cast(@RSTART as varchar)  + ' and ' +cast(@REND as varchar)  + ' '

--select @querysql
execute( @querysql)
--EXECUTE sp_executesql @SQLQuery, @ParameterDefinition, @EmpID
GO
