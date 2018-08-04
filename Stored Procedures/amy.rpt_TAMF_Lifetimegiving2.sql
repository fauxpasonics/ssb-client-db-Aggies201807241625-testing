SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_TAMF_Lifetimegiving2] as
select  'ADNumber|AccountName|FirstName|MiddleInitial|LastName|LifetimeGiving|status|SpouseName|AlumniInfo|SpouseAlumniInfo|Salutation|PK|PrimaryAddress|Code|AttnName|Company|Address1|Address2|Address3|City|State|Zip|County|Country|Email|Birthday|SpouseBirthday|contactid|PrefClassYear|DonorType' l 
union all
SELECT cast(Contact.ADNumber  as varchar)+ '|'+
isnull(Contact.AccountName,'') + '|'+
isnull(Contact.FirstName,'')+ '|'+
isnull(null,'')+ '|'+
isnull(Contact.LastName,'')+ '|'+ isnull(cast(Contact.LifetimeGiving as varchar), '')+ '|' +
case when Contact.Status = 'Lifetime' then 'Active' else Contact.Status end + '|'+
isnull(Contact.SpouseName, '')+ '|'+
isnull(Contact.AlumniInfo, '')+ '|'+ 
isnull(Contact.SpouseAlumniInfo, '')+ '|'+
isnull(Contact.Salutation collate database_default , '') + '|'+
isnull(cast(addressid as varchar), '') + '|'+
'1'+ '|'+
isnull(null, '')+ '|'+
isnull(careof, '')+ '|'+ 
isnull(null, '')+ '|'+
isnull(addr1, '')+ '|'+ 
isnull(addr2, '')+ '|'+ 
isnull(null, '')+ '|'+
isnull(City, '')+ '|'+ 
isnull(State, '')+ '|'+ 
isnull(Zip, '')+ '|'+
isnull(null, '')+ '|'+ 
isnull(null, '')+ '|'+ 
isnull(Email, '')+ '|'+ 
isnull(cast(Birthday as varchar), '')+ '|'+
isnull(cast(SpouseBirthday as varchar), '')+ '|'+ 
isnull(cast(contactid as varchar), '') + '|'+
isnull(PrefClassYear, '')+ '|'+
isnull(donortype, '')  
FROM patronextendedinfo_vw Contact 
--left join advcontactaddresses ContactAddresses ON ContactAddresses.ContactID = Contact.ContactID
--left join advQAContactExtendedInfo CC on CC.contactid = Contact.contactid
--where contact.adnumber  < 30000
GO
