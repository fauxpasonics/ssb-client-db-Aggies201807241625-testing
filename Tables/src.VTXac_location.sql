CREATE TABLE [src].[VTXac_location]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locationid] [int] NULL,
[description] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[server] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [smallint] NULL,
[lastupdated] [datetime2] (6) NULL,
[current_status] [smallint] NULL,
[suite_lock_enabled] [smallint] NULL,
[remotepollenabled] [numeric] (10, 0) NULL
)
GO
