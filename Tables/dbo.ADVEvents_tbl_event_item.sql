CREATE TABLE [dbo].[ADVEvents_tbl_event_item]
(
[id] [int] NOT NULL,
[event_group_id] [int] NOT NULL,
[sort_order] [int] NOT NULL,
[title] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL,
[descr] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optional] [bit] NULL,
[unit] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [money] NULL,
[max_qty] [int] NOT NULL,
[category_id_list] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[max_capacity] [int] NOT NULL,
[sold_out_behavior] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[other_info] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zero_qty] [bit] NOT NULL,
[show_qty_avail] [bit] NOT NULL,
[price_double] [money] NULL,
[price_triple] [money] NULL,
[price_quad] [money] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
