CREATE TABLE [amy].[SeatAllocation]
(
[SeatAllocationID] [int] NOT NULL IDENTITY(1, 1),
[ProgramID] [int] NULL,
[ProgramCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramTypeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatAreaID] [int] NOT NULL,
[SeatAreaName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatAllotmentID] [int] NOT NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramTypeCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [money] NULL,
[primaryallocation] [bit] NULL,
[sporttype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inactive_ind] [bit] NULL,
[primarystartyear] [int] NULL,
[primaryendyear] [int] NULL,
[capyearstart] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop trigger [amy].[AUR_SeatAllocation]
CREATE  TRIGGER [amy].[AUR_SeatAllocation] ON [amy].[SeatAllocation]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SeatAllocation T
JOIN INSERTED I
ON I.SeatAllocationID = T.SeatAllocationID
End
GO
DISABLE TRIGGER [amy].[AUR_SeatAllocation] ON [amy].[SeatAllocation]
GO
ALTER TABLE [amy].[SeatAllocation] ADD CONSTRAINT [PK__SeatAllo__A30A31773A1B5D2C] PRIMARY KEY CLUSTERED  ([SeatAllocationID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SeatAllocation_ProgramID] ON [amy].[SeatAllocation] ([ProgramID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SeatAllocation_SeatAreaID] ON [amy].[SeatAllocation] ([SeatAreaID])
GO
