CREATE TABLE [dbo].[ADVEvents_tbl_order_line]
(
[id] [int] NOT NULL,
[order_id] [int] NULL,
[product_id] [int] NULL,
[qty] [int] NULL,
[price] [decimal] (19, 4) NULL,
[donation] [decimal] (19, 4) NULL,
[comment] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[options] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[group_id] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewal_descr] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewal_programid] [int] NULL,
[pos_ticket_id] [int] NULL,
[price_code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_update_date] [datetime] NULL,
[va_offerid] [int] NULL,
[va_groupid] [int] NULL,
[va_price] [money] NULL,
[va_pricecodeid] [int] NULL,
[va_pricelevelid] [int] NULL,
[va_statuscodeid] [int] NULL,
[va_neighborhoodid] [int] NULL,
[va_sectionid] [int] NULL,
[va_rowid] [int] NULL,
[va_seatid_list] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_eventid] [int] NULL,
[va_seatgroupid] [int] NULL,
[va_zoneid] [int] NULL,
[kylefield_item_code] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event_group] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event_item_id] [int] NOT NULL,
[stsl_data] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_orderid] [int] NULL,
[va_neighborhood] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_info] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_price_code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_section] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_row] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[va_parentid] [int] NULL,
[prior_donation_payment] [money] NULL,
[va_seat] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVEvents_tbl_order_line_EC16138069B68E838AA4939001233389] ON [dbo].[ADVEvents_tbl_order_line] ([event_item_id]) INCLUDE ([order_id], [qty])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVEvents_tbl_order_line_5DC98F7DC6F3077BE5E395E3902CEC9D] ON [dbo].[ADVEvents_tbl_order_line] ([product_id], [renewal_descr]) INCLUDE ([order_id])
GO
