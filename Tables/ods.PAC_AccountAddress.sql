CREATE TABLE [ods].[PAC_AccountAddress]
(
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AddressTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AddressTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AddressTypeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AddressTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[MailName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CareOf] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address1] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[County] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RegionCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RegionCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RegionCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EffectiveFrom] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveTo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveYear] [int] NULL,
[IsEffectiveYearly] [bit] NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_AccountAddress] ON [ods].[PAC_AccountAddress]
GO
