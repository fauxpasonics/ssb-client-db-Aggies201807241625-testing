CREATE TABLE [amy].[fstamubids]
(
[ticket_id] [bigint] NULL,
[event_owner_id] [int] NULL,
[event_id] [bigint] NULL,
[account_id] [bigint] NULL,
[bid_id] [bigint] NULL,
[bid_status] [nvarchar] (53) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bid_action] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bid_ticket_quantity] [int] NULL,
[bid_price_per_ticket] [decimal] (28, 10) NULL,
[bid_placed_datetime] [datetime] NULL,
[bid_expire_datetime] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bid_went_inactive_datetime] [datetime] NULL,
[update_datetime] [datetime] NULL,
[listing_id] [bigint] NULL
)
GO
