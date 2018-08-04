SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view  [amy].[PatronExtendedInfo_vw_new] as
 select 
 null contactid,
 p.accountid accountid, 
  p.accountid patron, 
  p.accountid adnumber,
  p.accountname accountname, 
  c.firstname, 
  c.lastname,
   stat.[Name] status,  dtype.Name  donortype, 
    d.LifetimeDonationAmt/100  lifetimegiving, 
   --d.CurrentPoints  after julyupdate
  ppp.actualpoints adjustedpp, 
  -- d.PointsRank after julyupdate
   ppp.rank PPRank,
   d.PublishName , 
   p.PreferredEmail Email,
  home.phonenumber homephone,
  bus.phonenumber  busphone, 
  cell.phonenumber cellphone,
  sal.SalutationName Salutation,
   case when  accounttypecode = 'P'  then    addr.MailName else acct_addr.MailName  end MailName,
  case when  accounttypecode = 'P'  then    addr.address1 else acct_addr.Address1  end addr1,
  case when  accounttypecode = 'P'  then    addr.address2 else acct_addr.address2  end addr2,
  case when  accounttypecode = 'P'  then    addr.careof else acct_addr.careof  end careof,
  case when  accounttypecode = 'P'  then
     case when addr.careof is not null then addr.careof else addr.address1  end
  else
     case when acct_addr.careof is not null then acct_addr.careof else acct_addr.address1  end
  end adj_Address1,    
  case when  accounttypecode = 'P'  then
     case when addr.careof is not null then addr.address1 else addr.address2 end 
  else   case when acct_addr.careof is not null then acct_addr.address1 else addr.address2 end 
  end
  adj_Address2, 
   case when  accounttypecode = 'P'  then
     case when addr.careof is not null then  addr.address2 else null end 
   else  case when acct_addr.careof is not null then  acct_addr.address2 else null end 
   end adj_Address3,  
    case when  accounttypecode = 'P'  then  addr.City else acct_addr.City end City , 
    case when  accounttypecode = 'P'  then   addr.State else acct_addr.State end State ,
    case when  accounttypecode = 'P'  then   addr.ZipCode else acct_addr.ZipCode end   zip,
   (select UDFValue from ods.PAC_AccountUDF  where accountid =  p.accountid  and udfdefinitionid = 'CLC1' and udfTypecode = 'A')   classyear,
   (select LoginName StaffAssigned from ods.PAC_AccountGeneralRep  ar,   dbo.PacUser pu where pu.clientid = 'TAM'  and ar.GeneralRepUserID = pu.PacUserID and  ar.accountid = p.accountid)  StaffAssigned,
   (select UDFValue from ods.PAC_AccountUDF  where accountid =  p.accountid  and udfdefinitionid= 'MGSTAT' and udfTypecode = 'A')   MGStatus,
     d.PublishName udf4,
    C.BirthDate   Birthday,
 ( select top 1 sc.birthdate  from  ods.PAC_Contact SC where p.PrimaryContactID <> sc.contactid and p.accountid = sc.accountid) SpouseBirthday,
     (select UDFValue from ods.PAC_AccountUDF  where accountid = p.accountid and udfdefinitionid = 'CLC1' and udfTypecode = 'A')  PrefClassYear,
  (select UDFValue from ods.PAC_AccountUDF  where accountid = p.accountid and udfdefinitionid = 'CLC2' and udfTypecode = 'A')  SpousePrefClassYear,
 ( select top 1 sc2.firstname from  ods.PAC_Contact SC2 where p.PrimaryContactID <> sc2.contactid and p.accountid = sc2.accountid)  SpouseName,
(select UDFValue from ods.PAC_AccountUDF  where accountid = p.accountid and udfdefinitionid = 'AI' and udfTypecode = 'A') AlumniInfo, 
(select UDFValue from ods.PAC_AccountUDF  where accountid = p.accountid and udfdefinitionid = 'SAI' and udfTypecode = 'A') SpouseAlumniInfo,
--addr.zid
null addressid,
d.DonorTypeCode,
d.DonorStatusCode,
 p.sys_createts SetupDate
  from ods.PAC_Account p
  left join dbo.Donor d on d.AccountID = p.accountid
  left join ods.PAC_Contact C on c.accountid = p.accountid and   p.PrimaryContactID = c.contactid
  left join ods.pac_contactaddress addr  on  --p.TicketMailAddrCodeDbID = addr.AddressTypeCodeDbID and p.TicketMailAddrCodeType = addr.AddressTypeCodeType 
                                        -- and p.TicketMailAddrCodeSubtype = addr.AddressTypeCodeSubtype and p.TicketMailAddrCode = addr.AddressTypeCode and 
                                         p.accountid = addr.accountid and  addr.ContactID = p.PrimaryContactID and    accounttypecode = 'P' 
  left join ods.PAC_AccountAddress  acct_addr on p.AccountID = acct_addr.AccountID    and accounttypecode = 'O' 
  left join  ods.PAC_ContactPhone Home on home.accountid = p.accountid  and  p.PrimaryContactID = home.contactid and home.phonetypecode = 'H'
  left join  ods.PAC_ContactPhone Bus on Bus.accountid = p.accountid and  p.PrimaryContactID = bus.contactid and bus.phonetypecode = 'B'
  left join  ods.PAC_ContactPhone cell on home.accountid = p.accountid and  p.PrimaryContactID = cell.contactid and cell.phonetypecode = 'C'
  --left join ods.pac_
  left join ods.PAC_CodeLanguage stat on stat.codetype = d.donorstatuscodetype and stat.codesubtype = d.donorstatuscodesubtype and stat.code = d.DonorStatusCode
  left join ods.PAC_CodeLanguage dtype on  dtype.codetype = d.donortypecodetype  and dtype.codesubtype =  d.donortypecodesubtype and dtype.code = d.DonorTypeCode
  left join    ods.PAC_AccountSalutation sal on sal.accountid = p.accountid and salutationcode = 'I' 
  left join   ods.PAC_AccountPPP ppp on ppp.accountid = p.accountid and prioritypointsprogramid = 'TAMA'
GO
