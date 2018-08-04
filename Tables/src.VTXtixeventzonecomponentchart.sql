CREATE TABLE [src].[VTXtixeventzonecomponentchart]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [int] NULL,
[tixevtznpricelevelcode] [numeric] (10, 0) NULL,
[tixevtznpricecodecode] [numeric] (10, 0) NULL,
[component1price] [numeric] (18, 4) NULL,
[component2price] [numeric] (18, 4) NULL,
[component3price] [numeric] (18, 4) NULL,
[component4price] [numeric] (18, 4) NULL,
[component5price] [numeric] (18, 4) NULL
)
GO
