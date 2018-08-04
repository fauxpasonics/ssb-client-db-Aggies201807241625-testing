CREATE TABLE [ods].[FS_resold_tickets]
(
[ticket_id] [bigint] NULL,
[event_owner_id] [bigint] NULL,
[event_id] [bigint] NULL,
[offer_listing_id] [bigint] NULL,
[seller_account_id] [bigint] NULL,
[buyer_account_id] [bigint] NULL,
[ticket_state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tickets] [int] NULL,
[buyer_invoice_id] [bigint] NULL,
[seller_invoice_id] [bigint] NULL,
[bid_id] [bigint] NULL,
[bid_price_per_ticket] [decimal] (8, 1) NULL,
[initiate_transfer_datetime] [datetime2] NULL,
[update_datetime] [datetime2] NULL,
[ticket_bid_id] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL,
[ETL_Sync_UpdatedDate] [datetime] NULL
)
GO
