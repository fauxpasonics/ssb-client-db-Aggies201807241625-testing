CREATE TABLE [dbo].[ADVAllocationCategory]
(
[CategoryID] [int] NOT NULL,
[CategoryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ADVAllocationCategory] ADD CONSTRAINT [PK__AllocationCatego__3EFD1AD8] PRIMARY KEY CLUSTERED  ([CategoryID])
GO
