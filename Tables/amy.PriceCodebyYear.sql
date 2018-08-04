CREATE TABLE [amy].[PriceCodebyYear]
(
[PriceCodebyYearID] [int] NOT NULL IDENTITY(1, 1),
[PriceCodeCode] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriceCodeName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SportType] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriorityPoints] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PriceGroupID] [int] NULL,
[PriceCodeID] [int] NULL,
[priorityeventsid] [int] NULL
)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [amy].[AUR_PriceTypebyYear] ON [amy].[PriceCodebyYear]
AFTER UPDATE
AS
Begin
Update T
Set T.UpdateDate = Getdate(), T.UpdateUser = User_name()
from amy.PriceCodebyYear T
JOIN INSERTED I
ON I.PriceCodebyYearID = T.PriceCodebyYearID
End
GO
DISABLE TRIGGER [amy].[AUR_PriceTypebyYear] ON [amy].[PriceCodebyYear]
GO
ALTER TABLE [amy].[PriceCodebyYear] ADD CONSTRAINT [PK__PriceCod__11746FB51B210994] PRIMARY KEY CLUSTERED  ([PriceCodebyYearID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_PriceTypebyYear_PriceTypeCode_SportType_Ticketyear] ON [amy].[PriceCodebyYear] ([PriceCodeCode], [SportType], [TicketYear])
GO
CREATE NONCLUSTERED INDEX [index_pricecodebyyear_priorityeventsid] ON [amy].[PriceCodebyYear] ([priorityeventsid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_PriceTypebyYear_SportType_Ticketyear] ON [amy].[PriceCodebyYear] ([SportType], [TicketYear])
GO
ALTER TABLE [amy].[PriceCodebyYear] WITH NOCHECK ADD CONSTRAINT [FK__PriceCode__Price__7E2D9D55] FOREIGN KEY ([PriceCodeID]) REFERENCES [amy].[PriceCode] ([PriceCodeID])
GO
ALTER TABLE [amy].[PriceCodebyYear] WITH NOCHECK ADD CONSTRAINT [FK__PriceCode__Price__7C4554E3] FOREIGN KEY ([PriceGroupID]) REFERENCES [amy].[PriceGroup] ([PriceGroupID])
GO
ALTER TABLE [amy].[PriceCodebyYear] WITH NOCHECK ADD CONSTRAINT [FK__PriceCode__prior__7D39791C] FOREIGN KEY ([priorityeventsid]) REFERENCES [amy].[PriorityEvents] ([priorityeventsid])
GO
ALTER TABLE [amy].[PriceCodebyYear] NOCHECK CONSTRAINT [FK__PriceCode__Price__7E2D9D55]
GO
ALTER TABLE [amy].[PriceCodebyYear] NOCHECK CONSTRAINT [FK__PriceCode__Price__7C4554E3]
GO
ALTER TABLE [amy].[PriceCodebyYear] NOCHECK CONSTRAINT [FK__PriceCode__prior__7D39791C]
GO
