CREATE TABLE [dbo].[TK_CUSTOMER_ACTIVITY]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CUSTOMER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VMC] [bigint] NOT NULL,
[ACTIVITY] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[YEARS_OF_PURCHASE] [int] NULL,
[WAITLIST_PRIORITY] [int] NULL,
[ZID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_dbo__TK_CUSTOMER_ACTIVITY] ON [dbo].[TK_CUSTOMER_ACTIVITY]
GO
