CREATE TABLE [amy].[athcontacts]
(
[id] [uniqueidentifier] NULL,
[FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (68) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street1] [nvarchar] (66) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street2] [nvarchar] (54) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL,
[creation_source] [nvarchar] (59) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promotion_cnt] [int] NULL,
[promo_opt_in] [bit] NULL,
[macid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorInterest] [bit] NULL,
[TicketsInterest] [bit] NULL,
[KidsInterest] [bit] NULL,
[MilitaryInterest] [bit] NULL,
[auction_id] [int] NULL,
[AuctionUserName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuctionLastLogin] [date] NULL,
[AuctionTotalBids] [int] NULL,
[AuctionCnt] [int] NULL,
[TMFInd] [bit] NULL,
[FSInd] [int] NULL,
[TicketingInd] [bit] NULL,
[OnlineAuctionInd] [bit] NULL,
[TMFSetupDate] [datetime] NULL,
[FSSetupDate] [datetime] NULL,
[TicketSetupDate] [datetime] NULL,
[OnlineAuctionSetupDate] [datetime] NULL,
[DonorNumber] [int] NULL,
[DonorAccountName] [nvarchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorLifetimeGiving] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorPriorityPoints] [float] NULL,
[DonorPPRank] [int] NULL,
[FSBirthDate] [datetime] NULL,
[FSBidCnt] [int] NULL,
[FSBidWins] [int] NULL,
[FSListingCnt] [int] NULL,
[TicketAccountNumber] [int] NULL,
[FB] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BSB] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MB] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WB] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SB] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TN] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TK] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shop_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shop_ind] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shop_order_count] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fullname] [nvarchar] (51) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fsaccount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VB] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contacttypeid] [uniqueidentifier] NULL,
[SW] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EQ] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[classyear] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GF] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[student_ind] [bit] NULL,
[concessions] [bit] NULL
)
GO
