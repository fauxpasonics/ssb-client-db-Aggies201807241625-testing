CREATE TABLE [ods].[PAC_AccountNote]
(
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NoteID] [uniqueidentifier] NOT NULL,
[AttachmentID] [uniqueidentifier] NULL,
[Description] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Expiration] [date] NULL,
[FileName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoteTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[NoteTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[NoteTypeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[NoteTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Subject] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsPrivate] [bit] NULL,
[OriginationUserID] [bigint] NULL,
[OriginationTime] [datetime] NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_AccountNote] ON [ods].[PAC_AccountNote]
GO
