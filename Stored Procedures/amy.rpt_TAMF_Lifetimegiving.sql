SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_TAMF_Lifetimegiving]
as
SELECT Contact.ADNumber, --adv_id, adv_sourname, 
--(select id_number + formal_pref_mail_name from dataqa..AdvanceClassYearInfo where other_id = Contact.contactid) advance_id,
Contact.AccountName, 
Contact.FirstName, 
Contact.MiddleInitial, 
Contact.LastName, 
Contact.LifetimeGiving, 
case when Contact.Status = 'Lifetime' then 'Active' else Contact.Status end status,
Contact.SpouseName,
Contact.AlumniInfo, 
Contact.SpouseAlumniInfo,
Contact.Salutation,
ContactAddresses.PK ,
ContactAddresses.PrimaryAddress,
ContactAddresses.Code,
ContactAddresses.AttnName, 
ContactAddresses.Company,
ContactAddresses.Address1, 
ContactAddresses.Address2, 
ContactAddresses.Address3,
ContactAddresses.City, 
ContactAddresses.State, 
ContactAddresses.Zip,
ContactAddresses.County, 
ContactAddresses.Country, 
Contact.Email, 
Contact.Birthday,
Contact.SpouseBirthday, 
Contact.contactid,
--CC.ContactType, 
CC.PrefClassYear,
Contact.udf2 DonorType
FROM advcontact Contact 
left join advcontactaddresses ContactAddresses ON ContactAddresses.ContactID = Contact.ContactID
left join advQAContactExtendedInfo CC on CC.contactid = Contact.contactid
GO
