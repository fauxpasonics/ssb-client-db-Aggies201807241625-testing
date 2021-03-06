CREATE TABLE [dbo].[TK_BC]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[BC_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[STATUS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CUSTOMER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEQ] [bigint] NULL,
[ITEM] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_PL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[I_PT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EVENT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LEVEL] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SECTION] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ROW] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SEAT] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SCAN_DATE] [datetime] NULL,
[SCAN_TIME] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCAN_LOC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCAN_CLUSTER] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCAN_GATE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCAN_RESPONSE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REDEEMED] [smallint] NULL,
[DELIVERY_ID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ATTENDED] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC_TYPE] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ZID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_BC] ADD CONSTRAINT [PK_TK_BC] PRIMARY KEY CLUSTERED  ([ETLSID], [BC_ID])
GO
CREATE NONCLUSTERED INDEX [IDX_ATTENDED] ON [dbo].[TK_BC] ([ATTENDED])
GO
CREATE NONCLUSTERED INDEX [IDX_CUSTOMER] ON [dbo].[TK_BC] ([CUSTOMER])
GO
CREATE NONCLUSTERED INDEX [IDX_ETLSID] ON [dbo].[TK_BC] ([ETLSID])
GO
CREATE NONCLUSTERED INDEX [IDX_EVENT] ON [dbo].[TK_BC] ([EVENT])
GO
CREATE NONCLUSTERED INDEX [IDX_I_PL] ON [dbo].[TK_BC] ([I_PL])
GO
CREATE NONCLUSTERED INDEX [IDX_I_PT] ON [dbo].[TK_BC] ([I_PT])
GO
CREATE NONCLUSTERED INDEX [IDX_ITEM] ON [dbo].[TK_BC] ([ITEM])
GO
CREATE NONCLUSTERED INDEX [IDX_SEASON] ON [dbo].[TK_BC] ([SEASON])
GO
