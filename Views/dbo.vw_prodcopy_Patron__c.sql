SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_Patron__c] AS SELECT  Id, IsDeleted, Name, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Patron_ID__c, Account__c, Contact__c, SSB_CRMSYSTEM_CONTACT_ID__c, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.Patron__c;
GO
