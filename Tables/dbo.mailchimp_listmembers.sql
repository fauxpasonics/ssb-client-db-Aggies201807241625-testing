CREATE TABLE [dbo].[mailchimp_listmembers]
(
[id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[email_address] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unique_email_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[email_type] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[merge_fields] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[interests] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stats] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ip_signup] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp_signup] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ip_opt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp_opt] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_rating] [int] NULL,
[last_changed] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vip] [bit] NULL,
[email_client] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_note] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[_links] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
