CREATE TABLE [amy].[fstamulisting]
(
[listing_ticket_id] [nvarchar] (63) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticket_id] [bigint] NULL,
[event_owner_id] [int] NULL,
[event_id] [bigint] NULL,
[account_id] [bigint] NULL,
[bid_notification_type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[listed_datetime] [datetime] NULL,
[asking_price] [decimal] (28, 10) NULL,
[auto_accept_bid_amount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity_listed] [int] NULL,
[quantity_sold] [int] NULL,
[unlisted_datetime] [datetime] NULL,
[minimum_bid_price] [decimal] (28, 10) NULL,
[minimum_split] [int] NULL,
[update_datetime] [datetime] NULL,
[listing_id] [bigint] NULL
)
GO
