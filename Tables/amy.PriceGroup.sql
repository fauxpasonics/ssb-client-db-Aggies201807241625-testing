CREATE TABLE [amy].[PriceGroup]
(
[PriceGroupID] [int] NOT NULL IDENTITY(1, 1),
[PriceGroupName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SportType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticketyearstart] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
--drop trigger [amy].[AUR_PriceGroup]
CREATE  TRIGGER [amy].[AUR_PriceGroup] ON [amy].[PriceGroup]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.PriceGroup T
JOIN INSERTED I
ON I.PriceGroupID = T.PriceGroupID
End
GO
DISABLE TRIGGER [amy].[AUR_PriceGroup] ON [amy].[PriceGroup]
GO
ALTER TABLE [amy].[PriceGroup] ADD CONSTRAINT [PK__PriceGro__86E70763BBD4A64C] PRIMARY KEY CLUSTERED  ([PriceGroupID])
GO
