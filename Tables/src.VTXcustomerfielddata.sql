CREATE TABLE [src].[VTXcustomerfielddata]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerid] [numeric] (38, 10) NULL,
[customerfieldid] [numeric] (38, 10) NULL,
[stringvalue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[datevalue] [datetime2] (6) NULL,
[numericvalue] [numeric] (10, 0) NULL
)
GO
