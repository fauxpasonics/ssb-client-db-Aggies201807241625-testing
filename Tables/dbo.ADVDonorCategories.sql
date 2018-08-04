CREATE TABLE [dbo].[ADVDonorCategories]
(
[PK] [int] NOT NULL,
[CategoryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CategoryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Locked] [bit] NOT NULL,
[ValueType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AffectsPriorityPoints] [bit] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
