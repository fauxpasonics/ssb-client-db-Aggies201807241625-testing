CREATE TABLE [apietl].[MailChimp_Lists_lists_campaign_defaults_2]
(
[ETL__MailChimp_Lists_lists_campaign_defaults_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Lists_lists_id] [uniqueidentifier] NULL,
[from_name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[from_email] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subject] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists_lists_campaign_defaults_2] ADD CONSTRAINT [PK__MailChim__A546F8C2EBE5F9F9] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists_lists_campaign_defaults_id])
GO
