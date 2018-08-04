CREATE TABLE [apietl].[MailChimp_ListMembers_Prod_0]
(
[ETL__MailChimp_ListMembers_Prod_id] [uniqueidentifier] NOT NULL,
[ETL__session_id] [uniqueidentifier] NOT NULL,
[ETL__insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__MailChimp__ETL____4EB3945D] DEFAULT (getutcdate()),
[ETL__multi_query_value_for_audit] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_id] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total_items] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod_0] ADD CONSTRAINT [PK__MailChim__540E2365BE98C0E9] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_ListMembers_Prod_id])
GO
