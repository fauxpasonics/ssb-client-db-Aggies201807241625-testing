CREATE TABLE [ods].[PAC_DW_DSTDates]
(
[DSTYear] [numeric] (4, 0) NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[DST] [int] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_DW_DSTDates] ON [ods].[PAC_DW_DSTDates]
GO
