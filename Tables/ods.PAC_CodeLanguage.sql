CREATE TABLE [ods].[PAC_CodeLanguage]
(
[CodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[CodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[Code] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[LanguageCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[Description] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_CodeLanguage] ON [ods].[PAC_CodeLanguage]
GO
