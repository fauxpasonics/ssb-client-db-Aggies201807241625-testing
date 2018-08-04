CREATE TABLE [apietl].[MailChimp_Lists_0]
(
[ETL__MailChimp_Lists_id] [uniqueidentifier] NOT NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__ETL____509BDCCF] DEFAULT (getutcdate()),
[ETL__multi_query_value_for_audit] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_items] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists_0] ADD CONSTRAINT [PK__MailChim__1E9DFCBD76B1A99C] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists_id])
GO
