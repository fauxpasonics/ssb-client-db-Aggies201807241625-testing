CREATE TABLE [src].[VTXaes]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userid] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aeroleid] [numeric] (38, 10) NULL
)
GO
