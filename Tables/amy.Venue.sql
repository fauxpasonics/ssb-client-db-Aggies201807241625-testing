CREATE TABLE [amy].[Venue]
(
[VenueId] [int] NOT NULL IDENTITY(1, 1),
[VenueName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__Venue__CreateDat__452A2A23] DEFAULT (getdate()),
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Venue__CreateUse__443605EA] DEFAULT (user_name()),
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_Venue] ON [amy].[Venue]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.Venue T
JOIN INSERTED I
ON I.VenueID = T.VenueID
End
GO
DISABLE TRIGGER [amy].[AUR_Venue] ON [amy].[Venue]
GO
ALTER TABLE [amy].[Venue] ADD CONSTRAINT [PK__Venue__3C57E5F22166D0CE] PRIMARY KEY CLUSTERED  ([VenueId])
GO
