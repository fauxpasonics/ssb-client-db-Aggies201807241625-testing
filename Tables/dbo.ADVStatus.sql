CREATE TABLE [dbo].[ADVStatus]
(
[code] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DonorStatement] [bit] NOT NULL,
[Locked] [bit] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
