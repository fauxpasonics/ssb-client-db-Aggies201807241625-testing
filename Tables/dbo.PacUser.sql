CREATE TABLE [dbo].[PacUser]
(
[PacUserID] [bigint] NOT NULL,
[ClientID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EmailAddr] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoginName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorUserID] [bigint] NULL,
[UserTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[UserTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[UserTypeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[UserTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LanguageCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
ALTER TABLE [dbo].[PacUser] ADD CONSTRAINT [PK_dbo_PacUser] PRIMARY KEY CLUSTERED  ([PacUserID])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_PacUser_LanguageCode] ON [dbo].[PacUser] ([LanguageCode])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_PacUser_UserType] ON [dbo].[PacUser] ([UserTypeCodeDbID], [UserTypeCodeType], [UserTypeCodeSubtype], [UserTypeCode])
GO
