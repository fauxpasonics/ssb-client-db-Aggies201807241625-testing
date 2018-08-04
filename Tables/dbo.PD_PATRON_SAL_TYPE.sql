CREATE TABLE [dbo].[PD_PATRON_SAL_TYPE]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PATRON] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VMC] [bigint] NOT NULL,
[SAL_TYPE] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SALUTATION] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[PD_PATRON_SAL_TYPE] ADD CONSTRAINT [PK_PD_PATRON_SAL_TYPE] PRIMARY KEY CLUSTERED  ([ETLSID], [PATRON], [VMC])
GO
CREATE NONCLUSTERED INDEX [IDX_ETLSID] ON [dbo].[PD_PATRON_SAL_TYPE] ([ETLSID])
GO
