CREATE TABLE [src].[VTXclients]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [numeric] (10, 0) NULL,
[name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[theme] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[auction_agency_percentage] [numeric] (10, 4) NULL,
[default_restrict_transfer] [smallint] NULL,
[default_restrict_resale] [smallint] NULL,
[default_waive_first_seller_fee] [smallint] NULL,
[flashseats_enabled] [smallint] NULL,
[default_event_owner_id] [numeric] (10, 0) NULL
)
GO
