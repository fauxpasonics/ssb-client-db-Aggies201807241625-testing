CREATE TABLE [dbo].[DonorCategory]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DonorCategoryID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[DonorCategoryValue] [nvarchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
ALTER TABLE [dbo].[DonorCategory] ADD CONSTRAINT [PK_dbo_DonorCategory] PRIMARY KEY CLUSTERED  ([OrganizationID], [AccountDbID], [AccountID], [DonorCategoryID])
GO
