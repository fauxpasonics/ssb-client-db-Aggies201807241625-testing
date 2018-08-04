CREATE TABLE [src].[VTXoffer_group_products]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_id] [numeric] (20, 0) NULL,
[product_id] [numeric] (20, 0) NULL,
[disp_order] [numeric] (20, 0) NULL,
[optional] [smallint] NULL
)
GO
