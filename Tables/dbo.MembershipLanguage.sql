CREATE TABLE [dbo].[MembershipLanguage]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[MembershipID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[DriveYear] [int] NOT NULL,
[LanguageCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[Name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
ALTER TABLE [dbo].[MembershipLanguage] ADD CONSTRAINT [PK_dbo_MembershipLanguage] PRIMARY KEY CLUSTERED  ([OrganizationID], [MembershipID], [DriveYear], [LanguageCode])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_MembershipLanguage_LanguageCode] ON [dbo].[MembershipLanguage] ([LanguageCode])
GO
