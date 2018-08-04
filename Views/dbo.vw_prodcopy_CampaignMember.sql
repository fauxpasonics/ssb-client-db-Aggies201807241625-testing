SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_CampaignMember] AS SELECT  Id, IsDeleted, CampaignId, LeadId, ContactId, Status, HasResponded, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, FirstRespondedDate, Name, Full_Campaign_Member_ID__c, Salutation, FirstName, LastName, Title, Street, City, State, PostalCode, Country, Email, Phone, Fax, MobilePhone, Description, DoNotCall, HasOptedOutOfEmail, HasOptedOutOfFax, LeadSource, CompanyOrAccount, Type, LeadOrContactId, LeadOrContactOwnerId, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.CampaignMember;
GO
