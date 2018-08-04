CREATE TABLE [dbo].[AllocationCategory]
(
[CategoryID] [int] NOT NULL,
[CategoryName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[AllocationCategory] ADD CONSTRAINT [PK__AllocationCatego__3EFD1AD8_a04fa63e-1ec3-4df8-a8d8-75e732b7f9c6] PRIMARY KEY CLUSTERED  ([CategoryID])
GO
