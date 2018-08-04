SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_DonorProfileGeneralInformation2  42654
CREATE procedure  [amy].[rpt_DonorProfileGeneralInformation2] (@ADNumber varchar(300)) as
select 1 
   RowId,
--replace(c.AccountName, '"', '''') 
AccountName, 
--replace(c.FirstName, '"', '''') 
c.FirstName, 
c.LastName, 
c.ADNumber, 
c.PHHome, 
c.PHBusiness, 
c.Mobile,
c.Email,  
c.Status,
c.UDF2 DonorType, 
cei.PrefClassYear "Alumni",
c.Birthday,
-- Spouse Information
c.SpouseName, 
cei.SpousePrefClassYear,
c.SpouseBirthday,
--Donor Address
ca.Address1, 
ca.Address2, 
ca.Address3, 
ca.City + ', ' + ca.State + ' ' + ca.zip "CityStateZip",
ca.City, 
ca.State, 
ca.Zip,
replace(replace(replace(ca.salutation, '"', ''),'&',''),'''','')  SalutationScrub,
ca.Salutation,
 vc.address1  tixAddress1,
 vc.address2 tixAddress2,
vc.city + ', ' + vc.state+ ' ' + vc.zip  tixCityStateZip,
replace(replace(replace(vc.salutation, '"', ''),'&',''),'''','')  tixSalutationScrub,
vc.salutation tixSalutation,
-- Major Gifts
replace(replace(replace(c.StaffAssigned, '"', ''),'&',''),'''','')  StaffAssignedScrub,
c.StaffAssigned "StaffAssigned", 
replace(replace(replace(c.UDF4, '"', ''),'&',''),'''','')  MajorGiftsNamingOppScrub,
c.UDF4 "MajorGiftsNamingOpp",
replace(replace(replace(c.UDF1, '"', ''),'&',''),'''','')  MajorGiftsStatusScrub,
c.UDF1 "MajorGiftsStatus", 
c.contactid    --Not shown but can be used for other queries
from advcontact c
left join advQAContactExtendedInfo cei on cei.contactid = c.contactid
left join advcontactaddresses ca on (c.ContactID = ca.ContactID and ca.PrimaryAddress = 1)
left join ods.VTXcustomers vc on vc.accountnumber = cast (c.adnumber as varchar)
--filtering
where c.adnumber = @ADNumber
GO
