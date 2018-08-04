CREATE TABLE [amy].[ath_stg_ContactsAuctions]
(
[prs_id] [int] NULL,
[prs_fname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_lname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_username] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_email] [nvarchar] (68) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street1] [nvarchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_last_login] [nvarchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_created] [datetime] NULL,
[total_bids_cast] [int] NULL,
[unique_auctions_bid_on] [int] NULL,
[earliest_bid] [datetime] NULL,
[latest_bid] [datetime] NULL,
[smallest_bid] [decimal] (28, 10) NULL,
[largest_bid] [decimal] (28, 10) NULL,
[average_bid] [decimal] (28, 10) NULL
)
GO
