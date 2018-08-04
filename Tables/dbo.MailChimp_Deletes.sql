CREATE TABLE [dbo].[MailChimp_Deletes]
(
[AccountNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeleteDate] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__Delet__768C7B8D] DEFAULT (getdate())
)
GO
