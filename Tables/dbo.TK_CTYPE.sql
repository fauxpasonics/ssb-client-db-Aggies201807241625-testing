CREATE TABLE [dbo].[TK_CTYPE]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[TYPE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[NAME] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LAST_DATETIME] [datetime] NULL,
[ZID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_CTYPE] ADD CONSTRAINT [PK_TK_CTYPE] PRIMARY KEY CLUSTERED  ([ETLSID], [TYPE])
GO
CREATE NONCLUSTERED INDEX [IDX_ETLSID] ON [dbo].[TK_CTYPE] ([ETLSID])
GO
CREATE NONCLUSTERED INDEX [IDX_TYPE] ON [dbo].[TK_CTYPE] ([TYPE])
GO