SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_OpportunityContactRole] AS SELECT  Id, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, OpportunityId, ContactId, Role, IsPrimary, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.OpportunityContactRole;
GO
