CREATE TABLE [dbo].[MailChimp_LoadAccounts]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OldEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[accountname] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorGroups] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdated] [datetime] NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_AccountNumber] ON [dbo].[MailChimp_LoadAccounts] ([accountnumber])
GO
