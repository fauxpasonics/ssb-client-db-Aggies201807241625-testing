CREATE TABLE [amy].[zz_fb_ark_2016]
(
[Season] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatType] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Obstructed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaskedDonorNumber] [int] NULL,
[Potential_Annual] [money] NULL,
[Potential_Ticket_amount] [money] NULL,
[Potential_Ticket_amount_w_fee] [money] NULL,
[actual_annual_paid] [money] NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatusdesc] [nvarchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[actual_ticket_with_fee] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatvaluebeforediscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatpriceafterdiscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
