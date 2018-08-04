CREATE TABLE [ods].[PAC_ContactRelationship]
(
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContactID] [uniqueidentifier] NOT NULL,
[RelatedAccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[RelatedAccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RelatedContactID] [uniqueidentifier] NOT NULL,
[RelationCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RelationCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RelationCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RelationCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[inverseRelationCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Comments] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_CreateIP] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_CreateTS] [datetime] NULL,
[sys_CreateUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_Status] [int] NULL,
[sys_UpdateIP] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_UpdateTS] [datetime] NULL,
[sys_UpdateUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_ContactRelationship] ON [ods].[PAC_ContactRelationship]
GO
