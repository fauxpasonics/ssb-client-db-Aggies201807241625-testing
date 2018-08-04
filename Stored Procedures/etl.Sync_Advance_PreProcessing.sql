SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[Sync_Advance_PreProcessing]
AS 

truncate table dbo.ADVContactDonorCategories;

truncate table dbo.ADVContactPointsSummary;

truncate table dbo.ADVContactTransHeader;

truncate table dbo.ADVContactTransLineItems;
GO
