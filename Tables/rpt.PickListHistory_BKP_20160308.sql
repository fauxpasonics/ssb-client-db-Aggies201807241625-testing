CREATE TABLE [rpt].[PickListHistory_BKP_20160308]
(
[tixeventid] [numeric] (10, 0) NULL,
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderID] [numeric] (10, 0) NULL,
[CustomerName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerType] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodecode] [numeric] (10, 0) NULL,
[DeliveryMethod] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[section] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[row] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seats] [nvarchar] (301) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Qty] [int] NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
