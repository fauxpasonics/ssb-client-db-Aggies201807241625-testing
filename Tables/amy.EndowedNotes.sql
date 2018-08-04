CREATE TABLE [amy].[EndowedNotes]
(
[EndowedNotesID] [int] NOT NULL IDENTITY(1, 1),
[adnumber] [int] NULL,
[DonorName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotesDescr] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotesType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndowedSetupID] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_EndowedNotes] ON [amy].[EndowedNotes]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.EndowedNotes T
JOIN INSERTED I
ON I.EndowedNotesID = T.EndowedNotesID
End
GO
DISABLE TRIGGER [amy].[AUR_EndowedNotes] ON [amy].[EndowedNotes]
GO
