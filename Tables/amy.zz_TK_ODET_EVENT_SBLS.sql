CREATE TABLE [amy].[zz_TK_ODET_EVENT_SBLS]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SEASON] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CUSTOMER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SEQ] [bigint] NOT NULL,
[VMC] [bigint] NOT NULL,
[SVMC] [bigint] NOT NULL,
[SEATBLOCKS] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ITEM] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EVENT] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LEVEL] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SECTION] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ROW] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FIRST_SEAT] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LAST_SEAT] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ZID] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
