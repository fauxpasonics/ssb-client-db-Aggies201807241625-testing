CREATE TABLE [dbo].[TixHistoryTest]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[OrderID] [numeric] (10, 0) NULL,
[CustomerName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryMethod] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[section] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[row] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seats] [nvarchar] (301) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [IDX06] ON [dbo].[TixHistoryTest] ([accountnumber])
GO
CREATE NONCLUSTERED INDEX [IDX05] ON [dbo].[TixHistoryTest] ([tixeventid])
GO
