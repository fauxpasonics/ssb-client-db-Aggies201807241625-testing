SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_Cases] AS SELECT  Id, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, CaseNumber, ContactId, AccountId, ParentId, SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, Status, Reason, Origin, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId, ContactPhone, ContactMobile, ContactEmail, ContactFax, LastViewedDate, LastReferencedDate, Full_Case_ID__c, Related_Sport__c, Seat_Location__c, Specify_Other__c, Sub_Type__c, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.Cases;
GO
