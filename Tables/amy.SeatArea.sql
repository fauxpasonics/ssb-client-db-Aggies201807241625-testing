CREATE TABLE [amy].[SeatArea]
(
[SeatAreaID] [int] NOT NULL IDENTITY(1, 1),
[SeatAreaName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locationID] [int] NOT NULL,
[SportType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatCount] [int] NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatingType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAP_Amount] [money] NULL,
[Annual_Amount] [money] NULL,
[Seats_included] [int] NULL,
[TermPre06012014] [int] NULL,
[TermPost06012014] [int] NULL,
[TicketPrice] [int] NULL,
[SeatRegionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatRegionID] [int] NULL,
[sportid] [int] NULL,
[seatareacode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_Amount] [money] NULL,
[ballenapricelevel] [int] NULL,
[Neighborhood] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[premium_ind] [bit] NULL,
[tixsyspriceleveldesc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelcode] [int] NULL,
[ticketpricewofee] [money] NULL,
[fundingreportid] [int] NULL,
[pacpricelevel] [int] NULL,
[pacpricelevel_alt1] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop trigger [amy].[AUR_SeatArea]
CREATE  TRIGGER [amy].[AUR_SeatArea] ON [amy].[SeatArea]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SeatArea T
JOIN INSERTED I
ON I.SeatAreaID = T.SeatAreaID
End
GO
DISABLE TRIGGER [amy].[AUR_SeatArea] ON [amy].[SeatArea]
GO
ALTER TABLE [amy].[SeatArea] ADD CONSTRAINT [PK__SeatArea__BD581C931655C67E] PRIMARY KEY CLUSTERED  ([SeatAreaID])
GO
CREATE NONCLUSTERED INDEX [seatarea_fundingmodel] ON [amy].[SeatArea] ([fundingreportid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SeatArea_SeatRegion] ON [amy].[SeatArea] ([SeatRegionID])
GO
CREATE NONCLUSTERED INDEX [index_seatarea_sportid] ON [amy].[SeatArea] ([sportid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SeatArea_SportType] ON [amy].[SeatArea] ([SportType])
GO
ALTER TABLE [amy].[SeatArea] WITH NOCHECK ADD CONSTRAINT [FK__SeatArea__SeatRe__0015E5C7] FOREIGN KEY ([SeatRegionID]) REFERENCES [amy].[SeatRegion] ([SeatRegionID])
GO
ALTER TABLE [amy].[SeatArea] WITH NOCHECK ADD CONSTRAINT [FK__SeatArea__sporti__010A0A00] FOREIGN KEY ([sportid]) REFERENCES [amy].[Sport] ([SportID])
GO
ALTER TABLE [amy].[SeatArea] NOCHECK CONSTRAINT [FK__SeatArea__SeatRe__0015E5C7]
GO
ALTER TABLE [amy].[SeatArea] NOCHECK CONSTRAINT [FK__SeatArea__sporti__010A0A00]
GO
