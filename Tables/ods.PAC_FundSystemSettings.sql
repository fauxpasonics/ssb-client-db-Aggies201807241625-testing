CREATE TABLE [ods].[PAC_FundSystemSettings]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AuthorizationModeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[AuthorizationModeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[AuthorizationModeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[AuthorizationModeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Address] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentDriveYear] [int] NULL,
[CurrentSeasonYear] [int] NULL,
[DriveYearEndingMonth] [int] NULL,
[EmailAddress] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WebAddress] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_FundSystemSettings] ON [ods].[PAC_FundSystemSettings]
GO
