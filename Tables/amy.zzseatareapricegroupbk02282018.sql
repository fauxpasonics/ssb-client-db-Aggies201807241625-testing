CREATE TABLE [amy].[zzseatareapricegroupbk02282018]
(
[SeatAreaPriceGroupID] [int] NOT NULL IDENTITY(1, 1),
[SeatRegionID] [int] NULL,
[SeatAreaID] [int] NULL,
[PriceGroupID] [int] NULL,
[CAP] [money] NULL,
[Annual] [money] NULL,
[CAPCredit] [money] NULL,
[AnnualCredit] [money] NULL,
[SeatsIncluded] [bit] NULL,
[SportType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticketyear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priorityeventsid] [int] NULL,
[Capital_Programid] [int] NULL,
[Annual_Programid] [int] NULL,
[Ticket_Amount] [money] NULL
)
GO
