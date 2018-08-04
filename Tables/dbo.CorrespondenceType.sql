CREATE TABLE [dbo].[CorrespondenceType]
(
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Locked] [bit] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[CorrespondenceType] ADD CONSTRAINT [PK_CorrespondenceType_cf546a80-9a09-492a-8bb3-cd2fa7cef310] PRIMARY KEY CLUSTERED  ([Type])
GO
