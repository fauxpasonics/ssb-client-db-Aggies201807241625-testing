CREATE TABLE [amy].[EndowedCreditsbyYear]
(
[EndowedCreditsbyYearID] [int] NOT NULL IDENTITY(1, 1),
[EndowedSetupID] [int] NOT NULL,
[ADNumber] [int] NULL,
[EndowedCreditTotal] [decimal] (10, 2) NULL,
[SeatRegionName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatRegionID] [int] NULL,
[Credit] [decimal] (10, 2) NULL,
[TicketQty] [int] NULL,
[RenewalYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Programid] [int] NULL,
[E] [int] NULL,
[EC] [int] NULL,
[ZCE] [int] NULL,
[DriveYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreditType] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Creditapplieddate] [datetime] NULL,
[seatareaid] [int] NULL,
[donationprogramid] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_EndowedCreditsbyYear] ON [amy].[EndowedCreditsbyYear]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.EndowedCreditsbyYear T
JOIN INSERTED I
ON I.EndowedCreditsbyYearID = T.EndowedCreditsbyYearID
End
GO
DISABLE TRIGGER [amy].[AUR_EndowedCreditsbyYear] ON [amy].[EndowedCreditsbyYear]
GO
CREATE NONCLUSTERED INDEX [nci_wi_EndowedCreditsbyYear_3927BC7CDA4BFD21C1B5F0992E1C5B21] ON [amy].[EndowedCreditsbyYear] ([EndowedSetupID]) INCLUDE ([Credit], [CreditType], [RenewalYear])
GO
