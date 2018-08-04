CREATE TABLE [apietl].[MailChimp_Lists_lists_contact_2]
(
[ETL__MailChimp_Lists_lists_contact_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Lists_lists_id] [uniqueidentifier] NULL,
[company] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists_lists_contact_2] ADD CONSTRAINT [PK__MailChim__3729BB7E0E4A4067] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists_lists_contact_id])
GO
