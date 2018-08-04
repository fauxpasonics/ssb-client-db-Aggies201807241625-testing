SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vw_prodcopy_UserRole] AS SELECT  Id, Name, ParentRoleId, RollupDescription, OpportunityAccessForAccountOwner, CaseAccessForAccountOwner, ContactAccessForAccountOwner, ForecastUserId, MayForecastManagerShare, LastModifiedDate, LastModifiedById, SystemModstamp, DeveloperName, PortalAccountId, PortalType, PortalAccountOwnerId, copyloaddate, ETL_Sync_DeltaHashKey FROM prodcopy.UserRole;
GO
