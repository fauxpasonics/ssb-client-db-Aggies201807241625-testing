CREATE TABLE [ods].[VTXtixeventzonepricechart]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[tixevtznpricelevelcode] [numeric] (10, 0) NULL,
[tixevtznpricecodecode] [numeric] (10, 0) NULL,
[tixevtznpricecharged] [numeric] (19, 4) NULL,
[print_price] [numeric] (19, 2) NULL,
[text_price] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [ods].[VTXtixeventzonepricechart] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCD1C2E71B3] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [idx_TixEventZonePriceChart_Event_IsDel] ON [ods].[VTXtixeventzonepricechart] ([ETL_IsDeleted], [tixeventid]) INCLUDE ([ETL_CreatedDate], [ETL_DeletedDate], [ETL_DeltaHashKey], [ETL_ID], [ETL_SourceFileName], [ETL_UpdatedDate], [print_price], [text_price], [tixeventzoneid], [tixevtznpricecharged], [tixevtznpricecodecode], [tixevtznpricelevelcode])
GO
CREATE NONCLUSTERED INDEX [idx_PriceChart_JoinCols] ON [ods].[VTXtixeventzonepricechart] ([ETL_IsDeleted], [tixeventid], [tixeventzoneid], [tixevtznpricelevelcode]) INCLUDE ([tixevtznpricecharged], [tixevtznpricecodecode])
GO
