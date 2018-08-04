CREATE TABLE [amy].[Sport]
(
[SportID] [int] NOT NULL IDENTITY(1, 1),
[SportType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SportDesc] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludePriorityPoints] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_Sport] ON [amy].[Sport]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.Sport T
JOIN INSERTED I
ON I.SportID = T.SportID
End
GO
DISABLE TRIGGER [amy].[AUR_Sport] ON [amy].[Sport]
GO
ALTER TABLE [amy].[Sport] ADD CONSTRAINT [PK__Sport__7A41AF1CF1C8C809] PRIMARY KEY CLUSTERED  ([SportID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SportType] ON [amy].[Sport] ([SportType])
GO
