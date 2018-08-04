SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view  [amy].[PatronExtendedInfo_vw_old] as
select
  null contactid,
  p.patron, 
  p.PATRON adnumber,
  p.mail_name accountname, 
  case when charindex(',', P.[NAME] )  <> 0 then substring(P.[Name], charindex(',', P.[NAME] ) +1,50)  else null end firstname,
 case when charindex(',', P.[NAME] )  <> 0 then substring(P.[Name], 1, charindex(',', P.[NAME] ) -1 )  else P.[Name] end lastname,
  stat.[Name] status,  dtype.Name  donortype, 
  d.LifetimeDonationAmt/100  lifetimegiving, 
  --d.CurrentPoints  after julyupdate
   hpp2.points adjustedpp, 
 -- d.PointsRank after julyupdate
  hpp2.rank PPRank,
  d.PublishName ,  
  Email.PHONE Email,
  home.phone homephone,
  bus.phone  busphone, 
  cell.phone cellphone,
  sal.Salutation Salutation,
  addr1,
  addr2,
  addr3 careof,
  case when addr3 is not null then addr.addr3 else addr.ADDR1  end adj_Address1,       
  case when addr3 is not null then addr.addr1 else addr.ADDR2 end  adj_Address2, 
     case when addr3 is not null then  addr.ADDR2 else null end  adj_Address3,  
     substring(zip.CSZ, 1, charindex(',',zip.CSZ)-1) City , substring(zip.CSZ, charindex(', ',zip.CSZ)+2,2) State ,
     addr.SYS_ZIP   zip ,
     zip.CSZ,
     (select UDFValue from dbo.AccountUDF  where accountid = p.patron and udfdefinitionid = 'CLC1' and udfTypecode = 'A')   classyear,
    (select LoginName StaffAssigned from AccountGeneralRep ar,  dbo.PacUser pu where pu.clientid = 'TAM'  and ar.GeneralRepUserID = pu.PacUserID and  ar.accountid = p.patron)
     StaffAssigned,
     (select UDFValue from dbo.AccountUDF  where accountid = p.patron and udfdefinitionid= 'MGSTAT' and udfTypecode = 'A')   MGStatus,
     d.PublishName udf4,
     birth_date1  Birthday,
     birth_date2 SpouseBirthday,
 (select UDFValue from dbo.AccountUDF  where accountid = p.patron and udfdefinitionid = 'CLC1' and udfTypecode = 'A')  PrefClassYear,
  (select UDFValue from dbo.AccountUDF  where accountid = p.patron and udfdefinitionid = 'CLC2' and udfTypecode = 'A')  SpousePrefClassYear,
  case when charindex(',', P.[NAME2] )  <> 0 then substring(P.[Name2], charindex(',', P.[NAME2] ) +1,50)  else null end SpouseName,
(select UDFValue from dbo.AccountUDF  where accountid = p.patron and udfdefinitionid = 'AI' and udfTypecode = 'A') AlumniInfo, 
(select UDFValue from dbo.AccountUDF  where accountid = p.patron and udfdefinitionid = 'SAI' and udfTypecode = 'A') SpouseAlumniInfo,
addr.zid addressid,
d.DonorTypeCode,
d.DonorStatusCode,
p.ENTRY_DATETIME SetupDate
from dbo.pd_patron p 
left join  dbo.PD_PATRON_PHONE_TYPE Email on Email.PATRON = p.patron and email.phone_type = 'E'
left join  dbo.PD_PATRON_PHONE_TYPE Home on home.PATRON = p.patron and home.phone_type = 'H'
left join  dbo.PD_PATRON_PHONE_TYPE Bus on Bus.PATRON = p.patron and Bus.phone_type = 'B'
left join  dbo.PD_PATRON_PHONE_TYPE cell on cell.PATRON = p.patron and cell.phone_type = 'C'
left join dbo.Donor d on d.AccountID = p.patron 
left join dbo.pd_patron_sal_type sal on sal.patron = p.PATRON and sal.SAL_TYPE =  'I'
left join dbo.codelanguage stat on stat.codetype = d.donorstatuscodetype and stat.codesubtype = d.donorstatuscodesubtype and stat.code = d.DonorStatusCode
left join dbo.codelanguage dtype on  dtype.codetype = d.donortypecodetype  and dtype.codesubtype =  d.donortypecodesubtype and dtype.code = d.DonorTypeCode
left join  dbo.PD_ADDRESS addr on addr.ADTYPE = 'P' and addr.patron = p.PATRON 
left join dbo.SYS_ZIP zip on zip.sys_zip =  case when charindex('-',addr.SYS_ZIP) <> 0 then substring(addr.SYS_ZIP, 1,(charindex('-',addr.SYS_ZIP)-1)) else addr.SYS_ZIP end 
left join amy. historical_priority_point_pacconv hpp2 on p.patron= hpp2.patron
GO
