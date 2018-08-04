SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[rpt_TAMF_Lifetimegiving_vw]
as
SELECT Contact.ADNumber, --adv_id, adv_sourname, 
--(select id_number + formal_pref_mail_name from dataqa..AdvanceClassYearInfo where other_id = Contact.contactid) advance_id,
Contact.AccountName, 
Contact.FirstName, 
null MiddleInitial, 
Contact.LastName, 
Contact.LifetimeGiving, 
case when Contact.Status = 'Lifetime' then 'Active' else Contact.Status end status,
Contact.SpouseName,
Contact.AlumniInfo, 
SpouseAlumniInfo,
Salutation,
addressid PK ,
1 PrimaryAddress,
null Code,
careof AttnName, 
null Company,
addr1 Address1, 
addr2 Address2, 
null Address3,
City, 
State, 
Zip,
null County, 
null Country, 
Contact.Email, 
convert(varchar,Contact.Birthday, 101) Birthday,
convert(varchar,Contact.SpouseBirthday, 101) SpouseBirthday, 
Contact.contactid,
--CC.ContactType, 
PrefClassYear,
DonorType
from amy.PatronExtendedInfo_vw contact
/*FROM advcontact Contact 
left join advcontactaddresses ContactAddresses ON ContactAddresses.ContactID = Contact.ContactID
left join advQAContactExtendedInfo CC on CC.contactid = Contact.contactid */
GO
