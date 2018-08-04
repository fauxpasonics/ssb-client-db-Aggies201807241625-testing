CREATE TABLE [apietl].[MailChimp_PutRequest__links_1]
(
[ETL__MailChimp_PutRequest__links_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_PutRequest_id] [uniqueidentifier] NULL,
[rel] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[href] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[targetSchema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[schema] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_PutRequest__links_1] ADD CONSTRAINT [PK__MailChim__3D9B4A031400816A] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_PutRequest__links_id])
GO
