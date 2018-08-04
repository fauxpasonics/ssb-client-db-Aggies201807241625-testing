CREATE TABLE [dbo].[Donor]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CanPublish] [bit] NULL,
[CreditStatusCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditStatusCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditStatusCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CreditStatusCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CurrentPoints] [bigint] NULL,
[DonorStatusCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorStatusCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorStatusCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorStatusCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorTypeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DonorTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FirstGiftDate] [datetime] NULL,
[FirstGiftAmt] [money] NULL,
[GreatestGiftDate] [datetime] NULL,
[GreatestGiftAmt] [money] NULL,
[LastGiftDate] [datetime] NULL,
[LastGiftAmt] [money] NULL,
[LifetimeDonationAmt] [money] NULL,
[PointsRank] [bigint] NULL,
[PublishName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YearsOfDonating] [int] NULL,
[LastUpdateStatisticsDate] [datetime] NULL,
[LastUpdatePriorityPointsDate] [datetime] NULL,
[LastUpdateMembershipDate] [datetime] NULL,
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
ALTER TABLE [dbo].[Donor] ADD CONSTRAINT [PK_dbo_Donor] PRIMARY KEY CLUSTERED  ([OrganizationID], [AccountDbID], [AccountID])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_Donor_CreditStatus] ON [dbo].[Donor] ([CreditStatusCodeDbID], [CreditStatusCodeType], [CreditStatusCodeSubtype], [CreditStatusCode])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_Donor_DonorStatus] ON [dbo].[Donor] ([DonorStatusCodeDbID], [DonorStatusCodeType], [DonorStatusCodeSubtype], [DonorStatusCode])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_Donor_DonorType] ON [dbo].[Donor] ([DonorTypeCodeDbID], [DonorTypeCodeType], [DonorTypeCodeSubtype], [DonorTypeCode])
GO
