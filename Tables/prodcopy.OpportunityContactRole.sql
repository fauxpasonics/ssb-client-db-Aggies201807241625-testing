CREATE TABLE [prodcopy].[OpportunityContactRole]
(
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDeleted] [bit] NULL,
[CreatedDate] [datetime] NULL,
[CreatedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL,
[LastModifiedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemModstamp] [datetime] NULL,
[OpportunityId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Role] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPrimary] [bit] NULL,
[copyloaddate] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [prodcopy].[OpportunityContactRole] ADD CONSTRAINT [PK__Opportun__3214EC07FE6639A9] PRIMARY KEY CLUSTERED  ([Id])
GO
