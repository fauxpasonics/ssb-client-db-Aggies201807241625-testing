CREATE TABLE [amy].[vtxticketordercustomcomments]
(
[accountnumber] [int] NULL,
[ordernumber] [int] NULL,
[ColName] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventlookupid] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coldesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedate] [datetime] NULL,
[vtxticketordercustomcommentsid] [int] NOT NULL IDENTITY(1, 1)
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_vtxticketordercustomcomments] ON [amy].[vtxticketordercustomcomments]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate()
from amy.vtxticketordercustomcomments T
JOIN INSERTED I
ON I.vtxticketordercustomcommentsid = T.vtxticketordercustomcommentsid
End
GO
DISABLE TRIGGER [amy].[AUR_vtxticketordercustomcomments] ON [amy].[vtxticketordercustomcomments]
GO
