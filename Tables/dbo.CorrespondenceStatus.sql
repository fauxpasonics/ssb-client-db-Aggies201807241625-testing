CREATE TABLE [dbo].[CorrespondenceStatus]
(
[Code] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Locked] [bit] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[CorrespondenceStatus] ADD CONSTRAINT [PK_CorrespondenceStatus_51b3feca-f7e5-45f9-b145-581f86314339] PRIMARY KEY CLUSTERED  ([Code])
GO
