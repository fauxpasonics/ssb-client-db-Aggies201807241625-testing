CREATE TABLE [dbo].[TK_ORDER_CHG]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CUSTOMER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VMC] [bigint] NOT NULL,
[CHG] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CHG_AMT] [numeric] (18, 2) NULL,
[CHG_BPTYPE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CHG_PAY] [numeric] (18, 2) NULL,
[ZID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[TK_ORDER_CHG] ADD CONSTRAINT [PK_TK_ORDER_CHG] PRIMARY KEY CLUSTERED  ([ETLSID], [SEASON], [CUSTOMER], [VMC])
GO
CREATE NONCLUSTERED INDEX [IDX_CUSTOMER] ON [dbo].[TK_ORDER_CHG] ([CUSTOMER])
GO
CREATE NONCLUSTERED INDEX [IDX_ETLSID] ON [dbo].[TK_ORDER_CHG] ([ETLSID])
GO
CREATE NONCLUSTERED INDEX [IDX_SEASON] ON [dbo].[TK_ORDER_CHG] ([SEASON])
GO
