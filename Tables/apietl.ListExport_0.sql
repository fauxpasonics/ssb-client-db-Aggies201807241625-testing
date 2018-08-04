CREATE TABLE [apietl].[ListExport_0]
(
[ListExport_id] [uniqueidentifier] NOT NULL,
[session_id] [uniqueidentifier] NOT NULL,
[insert_datetime] [datetime] NOT NULL CONSTRAINT [DF__ListExpor__inser__48FABB07] DEFAULT (getutcdate()),
[multi_query_value_for_audit] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[error] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[code] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[ListExport_0] ADD CONSTRAINT [PK__ListExpo__C7D8D903568FB374] PRIMARY KEY CLUSTERED  ([ListExport_id])
GO
