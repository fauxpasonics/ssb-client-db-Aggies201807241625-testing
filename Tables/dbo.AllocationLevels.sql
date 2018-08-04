CREATE TABLE [dbo].[AllocationLevels]
(
[MembID] [int] NOT NULL,
[TransYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramID] [int] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[AllocationLevels] ADD CONSTRAINT [PK_AllocationLevels_4ee6813c-d305-42ce-a61f-dc123c075d50] PRIMARY KEY CLUSTERED  ([ProgramID], [MembID], [TransYear])
GO
