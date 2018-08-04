CREATE TABLE [src].[VTXcustomerfields]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [numeric] (10, 0) NULL,
[name] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logchanges] [smallint] NULL,
[customerfieldlistid] [numeric] (10, 0) NULL,
[required] [smallint] NULL,
[active] [smallint] NULL,
[fieldtype] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storagetype] [numeric] (38, 10) NULL,
[readonly] [smallint] NULL,
[visible] [smallint] NULL,
[maxlength] [numeric] (20, 0) NULL
)
GO
