CREATE TABLE [dbo].[TK_PTABLE_PRLEV]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PTABLE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PL_NAME] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_PTABLE_PRLEV] ADD CONSTRAINT [PK_TK_PTABLE_PRLEV] PRIMARY KEY CLUSTERED  ([ETLSID], [SEASON], [PTABLE], [PL])
GO
CREATE NONCLUSTERED INDEX [IDX_ETLSID] ON [dbo].[TK_PTABLE_PRLEV] ([ETLSID])
GO
CREATE NONCLUSTERED INDEX [IDX_PL] ON [dbo].[TK_PTABLE_PRLEV] ([PL])
GO
