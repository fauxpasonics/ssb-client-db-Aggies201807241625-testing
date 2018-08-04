CREATE TABLE [amy].[SeatAllotment]
(
[SeatAllotmentID] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--drop trigger [amy].[AUR_SeatAllotment]
CREATE  TRIGGER [amy].[AUR_SeatAllotment] ON [amy].[SeatAllotment]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.SeatAllotment T
JOIN INSERTED I
ON I.SeatAllotmentID = T.SeatAllotmentID
End
GO
DISABLE TRIGGER [amy].[AUR_SeatAllotment] ON [amy].[SeatAllotment]
GO
ALTER TABLE [amy].[SeatAllotment] ADD CONSTRAINT [PK__SeatAllo__A673BC5D8BC06842] PRIMARY KEY CLUSTERED  ([SeatAllotmentID])
GO
