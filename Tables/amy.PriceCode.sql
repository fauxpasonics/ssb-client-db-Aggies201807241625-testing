CREATE TABLE [amy].[PriceCode]
(
[PriceCodeID] [int] NOT NULL IDENTITY(1, 1),
[PriceCodeCode] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriceCodeName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SportType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorityPoints] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodecode] [int] NULL,
[sportid] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_PriceCode] ON [amy].[PriceCode]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.PriceCode T
JOIN INSERTED I
ON I.PriceCodeID = T.PriceCodeID
End
GO
DISABLE TRIGGER [amy].[AUR_PriceCode] ON [amy].[PriceCode]
GO
ALTER TABLE [amy].[PriceCode] ADD CONSTRAINT [PK__PriceCod__07847A2334F29A57] PRIMARY KEY CLUSTERED  ([PriceCodeID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_PriceType_SportType] ON [amy].[PriceCode] ([SportType])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_PriceCode_tixsyspricecodecode] ON [amy].[PriceCode] ([tixsyspricecodecode])
GO
ALTER TABLE [amy].[PriceCode] WITH NOCHECK ADD CONSTRAINT [FK__PriceCode__sport__7B5130AA] FOREIGN KEY ([sportid]) REFERENCES [amy].[Sport] ([SportID])
GO
ALTER TABLE [amy].[PriceCode] NOCHECK CONSTRAINT [FK__PriceCode__sport__7B5130AA]
GO
