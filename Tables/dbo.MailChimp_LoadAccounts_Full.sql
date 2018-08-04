CREATE TABLE [dbo].[MailChimp_LoadAccounts_Full]
(
[AccountNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AccountName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorGroups] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_AccountNumber] ON [dbo].[MailChimp_LoadAccounts_Full] ([AccountNumber])
GO
CREATE NONCLUSTERED INDEX [IX_email] ON [dbo].[MailChimp_LoadAccounts_Full] ([Email])
GO
