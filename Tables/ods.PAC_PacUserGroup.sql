CREATE TABLE [ods].[PAC_PacUserGroup]
(
[ClientID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PacUserGroupID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SKIPACTIVATION] [bit] NULL,
[ManageMyAccountPassword] [bit] NULL,
[ManageRoles] [bit] NULL,
[ManageUsers] [bit] NULL,
[ViewActiveUsers] [bit] NULL,
[ManageChannels] [bit] NULL,
[ManagePasswordPolicy] [bit] NULL,
[AssignDeviceLocation] [bit] NULL,
[ResetDevice] [bit] NULL,
[SkipIPValidation] [bit] NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_PacUserGroup] ON [ods].[PAC_PacUserGroup]
GO
