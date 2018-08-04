SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_Campaign] AS SELECT  Id, IsDeleted, Name, ParentId, Type, Status, StartDate, EndDate, ExpectedRevenue, BudgetedCost, ActualCost, ExpectedResponse, NumberSent, IsActive, Description, NumberOfLeads, NumberOfConvertedLeads, NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, AmountAllOpportunities, AmountWonOpportunities, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, CampaignMemberRecordTypeId, Full_Campaign_ID__c, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.Campaign;
GO
