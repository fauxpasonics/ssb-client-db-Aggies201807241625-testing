CREATE TABLE [amy].[SeatAreaPriceGroup]
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop trigger [amy].[AUR_SeatAreaPriceGroup]
CREATE  TRIGGER [amy].[AUR_SeatAreaPriceGroup] ON [amy].[SeatAreaPriceGroup]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SeatAreaPriceGroup T
JOIN INSERTED I
ON I.SeatAreaPriceGroupID = T.SeatAreaPriceGroupID
End
GO
DISABLE TRIGGER [amy].[AUR_SeatAreaPriceGroup] ON [amy].[SeatAreaPriceGroup]
GO
ALTER TABLE [amy].[SeatAreaPriceGroup] ADD CONSTRAINT [PK__SeatArea__B05A02697367CE46] PRIMARY KEY CLUSTERED  ([SeatAreaPriceGroupID])
GO
CREATE NONCLUSTERED INDEX [index_seatareapricegroup_priorityeventsid] ON [amy].[SeatAreaPriceGroup] ([priorityeventsid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SeatAreaPriceGroup_SeatAreaID_PriceGroupID] ON [amy].[SeatAreaPriceGroup] ([SeatAreaID], [PriceGroupID])
GO
CREATE NONCLUSTERED INDEX [idx_SeatAreaPriceGroup_seatareaid_pricegroupid_sporttype_ticketyear] ON [amy].[SeatAreaPriceGroup] ([SeatAreaID], [PriceGroupID], [SportType], [Ticketyear])
GO
ALTER TABLE [amy].[SeatAreaPriceGroup] WITH NOCHECK ADD CONSTRAINT [FK__SeatAreaP__prior__01FE2E39] FOREIGN KEY ([priorityeventsid]) REFERENCES [amy].[PriorityEvents] ([priorityeventsid])
GO
ALTER TABLE [amy].[SeatAreaPriceGroup] WITH NOCHECK ADD CONSTRAINT [FK__SeatAreaP__SeatA__02F25272] FOREIGN KEY ([SeatAreaID]) REFERENCES [amy].[SeatArea] ([SeatAreaID])
GO
ALTER TABLE [amy].[SeatAreaPriceGroup] NOCHECK CONSTRAINT [FK__SeatAreaP__prior__01FE2E39]
GO
ALTER TABLE [amy].[SeatAreaPriceGroup] NOCHECK CONSTRAINT [FK__SeatAreaP__SeatA__02F25272]
GO
