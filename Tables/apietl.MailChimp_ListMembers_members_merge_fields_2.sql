CREATE TABLE [apietl].[MailChimp_ListMembers_members_merge_fields_2]
(
[MailChimp_ListMembers_members_merge_fields_id] [uniqueidentifier] NOT NULL,
[MailChimp_ListMembers_members_id] [uniqueidentifier] NULL,
[FNAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LNAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCTNAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCTNUMBER] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL1NAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL1PPL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL1RCPT] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL1TTL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL1AMTDU] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL2NAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL2PPL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL2RCPT] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL2TTL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL2AMTDU] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL3NAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL3PPL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL3RCPT] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL3TTL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL3AMTDU] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL4NAME] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL4PPL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL4RCPT] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL4TTL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVL4AMTDU] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRVLNUMBER] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECMBBTIX] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_members_merge_fields_2] ADD CONSTRAINT [PK__MailChim__B7DADC7BD1004233] PRIMARY KEY CLUSTERED  ([MailChimp_ListMembers_members_merge_fields_id])
GO
