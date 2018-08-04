CREATE TABLE [etl].[MailChimp_LoadLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[EmailAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NULL
)
GO
ALTER TABLE [etl].[MailChimp_LoadLog] ADD CONSTRAINT [PK__MailChim__5E548648E468FBDB] PRIMARY KEY CLUSTERED  ([LogId])
GO
CREATE NONCLUSTERED INDEX [IDX_EmailAddress] ON [etl].[MailChimp_LoadLog] ([EmailAddress])
GO
