CREATE TABLE [ods].[VTXfees]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
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
ALTER TABLE [ods].[VTXfees] ADD CONSTRAINT [PK__VTXfees__7EF6BFCDF4E756F1] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
