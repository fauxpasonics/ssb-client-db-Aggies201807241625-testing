CREATE TABLE [dbo].[ADVFundRaisingDivision]
(
[DivisionID] [int] NOT NULL,
[DivisionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
