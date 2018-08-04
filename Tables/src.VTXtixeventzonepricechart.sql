CREATE TABLE [src].[VTXtixeventzonepricechart]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
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
