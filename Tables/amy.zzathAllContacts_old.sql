CREATE TABLE [amy].[zzathAllContacts_old]
(
[id] [uniqueidentifier] NULL,
[prs_id] [int] NULL,
[FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prs_username] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (68) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[average_bid] [decimal] (28, 10) NULL,
[adnumber] [int] NULL,
[tmfaccountname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmfstatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tmfsetupdate] [datetime] NULL,
[tmflifetimegiving] [money] NULL,
[PriorityPoints] [float] NULL,
[PPRank] [int] NULL,
[seatcount] [int] NULL,
[sports] [int] NULL,
[fsfirstname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fslastname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fsbirthdate] [datetime] NULL,
[fscreatedate] [datetime] NULL,
[flashseats] [int] NULL,
[TMFMember] [int] NOT NULL,
[fsbidcnt] [int] NULL,
[bidwins] [int] NULL,
[bidperticket] [decimal] (38, 10) NULL,
[fslistingcnt] [int] NULL,
[bidticketcnt] [int] NULL,
[promotion_cnt] [int] NULL,
[macid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promo_opt_in] [bit] NULL,
[create_date] [datetime] NULL,
[creation_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorInterest] [bit] NULL,
[TicketsInterest] [bit] NULL,
[KidsInterest] [bit] NULL,
[MilitaryInterest] [bit] NULL
)
GO
