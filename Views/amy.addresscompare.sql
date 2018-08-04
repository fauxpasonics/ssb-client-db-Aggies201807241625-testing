SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[addresscompare] as
select alist.*,
case when isnull(AdvSSBAddressPrimaryStreet,'') <> isnull(VTSSBAddressPrimaryStreet,'') then 'X' else null end PrimaryStreetCompare,
case when isnull(AdvSSBAddressPrimaryCity,'') <> isnull(VTSSBAddressPrimaryCity,'') then 'X' else null end PrimaryCityCompare,
case when isnull(AdvSSBAddressPrimaryState,'') <> isnull(VTSSBAddressPrimaryState ,'') then 'X' else null end PrimaryStateCompare,
case when isnull(AdvSSBAddressPrimaryZip,'') <> isnull(VTSSBAddressPrimaryZip,'') then 'X' else null end PrimaryZipCompare,
case when isnull(AdvSSBFirstName,'') <> isnull(VTSSBFirstName,'') then 'X' else null  end FirstNameCompare,
case when isnull(AdvSSBlastname,'') <> isnull(VTSSBlastname,'') then 'X' else null  end lastnameCompare,
case when isnull(AdvSSBemailprimary,'') <> isnull(VTSSBemailprimary,'') then 'X' else null end emailprimaryCompare,
case when isnull(AdvSSBphonehome,'') <> isnull(VTSSBphonehome,'') then 'X' else null  end phonehomeCompare
from (
select alldonors.firstname, alldonors.lastname, alldonors.SSB_CRMSYSTEM_CONTACT_ID  , 
--advssb
advssb.SSB_CRMSYSTEM_CONTACT_ID advssbSSB_CRMSYSTEM_CONTACT_ID ,
AdvSSB.SSB_CRMSYSTEM_PRIMARY_FLAG advSSB_CRMSYSTEM_PRIMARY_FLAG , AdvSSB.accountid  AdvSSBaccountid, AdvSSB.extattribute11 AdvSSBextattribute11, 
AdvSSB.firstname AdvSSBfirstname, AdvSSB.lastname AdvSSBlastname,  AdvSSB.MiddleName AdvSSBMiddleName, AdvSSB.extattribute4 AdvSSBaccountname, AdvSSB.suffix   AdvSSBsuffix, 
AdvSSB.ssid  contactid, AdvSSB.contactguid AdvSSBcontactguid, AdvSSB.extattribute9 AdvSSBextattribute9, AdvSSB.ExtAttribute10 AdvSSBExtAttribute10, AdvSSB.emailprimary AdvSSBemailprimary,
AdvSSB.phoneprimary AdvSSBphoneprimary, AdvSSB.phonehome AdvSSBphonehome,
AdvSSB.AddressPrimaryStreet AdvSSBAddressPrimaryStreet, AdvSSB.AddressPrimaryCity  AdvSSBAddressPrimaryCity, AdvSSB.AddressPrimaryState  AdvSSBAddressPrimaryState, 
AdvSSB.AddressPrimaryZip AdvSSBAddressPrimaryZip, AdvSSB.AddressPrimaryCounty AdvSSBAddressPrimaryCounty, AdvSSB.AddressPrimaryCountry  AdvSSBAddressPrimaryCountry, AdvSSB.AddressPrimaryIsCleanStatus AdvSSBAddressIsCleanStatus,
--vtssb
vtssb.SSB_CRMSYSTEM_CONTACT_ID vtssbSSB_CRMSYSTEM_CONTACT_ID ,
VTSSB.SSB_CRMSYSTEM_PRIMARY_FLAG VTSSB_CRMSYSTEM_PRIMARY_FLAG , VTSSB.accountid  VTSSBaccountid, VTSSB.extattribute11 VTSSBextattribute11, 
VTSSB.firstname VTSSBfirstname, VTSSB.lastname VTSSBlastname, VTSSB.extattribute4 VTSSBaccountname, VTSSB.suffix   VTSSBsuffix, 
VTSSB.ssid  veritixid, VTSSB.contactguid VTSSBcontactguid, VTSSB.extattribute9 VTSSBextattribute9, VTSSB.ExtAttribute10 VTSSBExtAttribute10, VTSSB.emailprimary VTSSBemailprimary,
VTSSB.phoneprimary VTSSBphoneprimary, VTSSB.phonehome VTSSBphonehome, 
VTSSB.AddressPrimaryStreet VTSSBAddressPrimaryStreet, VTSSB.AddressPrimaryCity  VTSSBAddressPrimaryCity, VTSSB.AddressPrimaryState  VTSSBAddressPrimaryState, 
VTSSB.AddressPrimaryZip VTSSBAddressPrimaryZip, VTSSB.AddressPrimaryCounty VTSSBAddressPrimaryCounty, VTSSB.AddressPrimaryCountry  VTSSBAddressPrimaryCountry, VTSSB.AddressPrimaryIsCleanStatus VTSSBAddressIsCleanStatus, 
--adv
adv.firstname advfirstname, adv.middleinitial advmiddleinitial,  adv.lastname advlastname, adv.suffix  advsuffix,  adv.accountname advaccountname, adv.address1 advaddress1, 
adv.address2 advaddress2, adv.city advcity, adv.state advstate, adv.zip advzip, 
--vtc
vtx.accountnumber vtxaccountnumber , vtx.id  vtxid, vtx.lastname vtxlastname, vtx.firstname vtxfirstname, vtx.middle vtxmiddle, vtx.phone1 vtxphone1,
vtx.phone2 vtxphone2, vtx.address1 vtxaddress1, vtx.address2 vtxaddress2, vtx.city vtxcity, vtx.state  vtxstate, vtx.email  vtxemail, 
vtx.zip vtxzip, vtx.fullname vtxfullname, vtx.prefix vtxprefix, vtx.suffix vtxsuffix
from 
(select distinct firstname, lastname, SSB_CRMSYSTEM_CONTACT_ID from dbo.vwDimCustomer_ModAcctId) alldonors
left join dbo.vwDimCustomer_ModAcctId  AdvSSB on  advSSB.SSB_CRMSYSTEM_CONTACT_ID  = alldonors.SSB_CRMSYSTEM_CONTACT_ID  and  advSSB.sourcesystem = 'Advantage'
left join dbo.vwDimCustomer_ModAcctId  VTSSB on  VTSSB.SSB_CRMSYSTEM_CONTACT_ID  = alldonors.SSB_CRMSYSTEM_CONTACT_ID  and  VTSSB.sourcesystem = 'Veritix'
left join (select c.*, address1,address2, city, state, zip  from advcontact c
          left join advcontactaddresses ca on c.contactid = ca.contactid and primaryaddress = 1 ) adv on adv.contactid = advSSB.ssid 
left join  ods.VTXcustomers  vtx     on vtx.id = vtSSB.ssid 
) alist
GO
