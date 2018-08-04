CREATE TABLE [ods].[PAC_DW_TimeZone]
(
[Code] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Offset] [numeric] (5, 2) NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_DW_TimeZone] ON [ods].[PAC_DW_TimeZone]
GO
