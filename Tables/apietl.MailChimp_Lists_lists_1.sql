CREATE TABLE [apietl].[MailChimp_Lists_lists_1]
(
[ETL__MailChimp_Lists_lists_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Lists_id] [uniqueidentifier] NULL,
[id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[permission_reminder] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[use_archive_bar] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notify_on_subscribe] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notify_on_unsubscribe] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[date_created] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_rating] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_type_option] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscribe_url_short] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subscribe_url_long] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beamer_address] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[visibility] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[double_optin] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[marketing_permissions] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists_lists_1] ADD CONSTRAINT [PK__MailChim__8ECDD839CD94CEF5] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists_lists_id])
GO
