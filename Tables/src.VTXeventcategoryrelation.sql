CREATE TABLE [src].[VTXeventcategoryrelation]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[categoryid] [numeric] (10, 0) NULL,
[createdate] [datetime2] (6) NULL,
[createdby] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
