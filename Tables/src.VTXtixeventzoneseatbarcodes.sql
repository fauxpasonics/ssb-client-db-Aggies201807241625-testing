CREATE TABLE [src].[VTXtixeventzoneseatbarcodes]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatbarcodeid] [numeric] (10, 0) NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[tixseatgroupid] [int] NULL,
[tixseatid] [numeric] (10, 0) NULL,
[barcode] [nvarchar] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scandatetime] [datetime2] (6) NULL,
[scanlocation] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clustercode] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gatenumber] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validationresponse] [smallint] NULL,
[initdate] [datetime2] (6) NULL
)
GO
