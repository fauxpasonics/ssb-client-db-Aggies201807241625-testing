CREATE TABLE [apietl].[MailChimp_ListMembers_0]
(
[MailChimp_ListMembers_id] [uniqueidentifier] NOT NULL,
[session_id] [uniqueidentifier] NOT NULL,
[insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__inser__4CCB4BEB] DEFAULT (getutcdate()),
[multi_query_value_for_audit] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_items] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_0] ADD CONSTRAINT [PK__MailChim__5165DDC93F883E4C] PRIMARY KEY CLUSTERED  ([MailChimp_ListMembers_id])
GO
