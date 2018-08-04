CREATE TABLE [src].[VTXfees]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [numeric] (20, 0) NULL,
[name] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product_id] [numeric] (20, 0) NULL,
[rollup_desc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_taxable] [smallint] NULL,
[application_method] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[print_on_ticket] [smallint] NULL,
[exp_date] [datetime2] (6) NULL,
[client_id] [numeric] (10, 0) NULL
)
GO
