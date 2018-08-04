SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_OpportunityLineItem] AS SELECT  Id, OpportunityId, SortOrder, PricebookEntryId, Product2Id, ProductCode, Name, Quantity, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsDeleted, Full_Opportunity_Product_ID__c, Donation__c, Is_OP_Donation__c, Is_OP_Season_Ticket__c, Season_Ticket__c, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.OpportunityLineItem;
GO
