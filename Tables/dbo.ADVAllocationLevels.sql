CREATE TABLE [dbo].[ADVAllocationLevels]
(
[MembID] [int] NOT NULL,
[TransYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramID] [int] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ADVAllocationLevels] ADD CONSTRAINT [PK_AllocationLevels_2ea54990-4d43-4f62-ba72-e052f1929506] PRIMARY KEY CLUSTERED  ([ProgramID], [MembID], [TransYear])
GO
