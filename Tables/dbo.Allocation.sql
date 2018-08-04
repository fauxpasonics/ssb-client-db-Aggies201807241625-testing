CREATE TABLE [dbo].[Allocation]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AllocationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AddToLifeTimeGiving] [bit] NULL,
[AddToYearsOfGiving] [bit] NULL,
[AllocationGroupID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[CharitablePct] [int] NULL,
[ConsumerFundDescription] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeadlineDay] [int] NULL,
[DeadlineMonth] [int] NULL,
[DeadlineYear] [int] NULL,
[DeadlineFactorCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DeadlineFactorCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DeadlineFactorCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DeadlineFactorCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[GLAccount] [nvarchar] (999) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsAnnualGift] [bit] NULL,
[IsExcludedFromDonationHistory] [bit] NULL,
[PriorityPointPct] [int] NULL,
[TerminalID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
ALTER TABLE [dbo].[Allocation] ADD CONSTRAINT [PK_dbo_Allocation] PRIMARY KEY CLUSTERED  ([OrganizationID], [AllocationID])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_Allocation_DeadlineFactor] ON [dbo].[Allocation] ([DeadlineFactorCodeDbID], [DeadlineFactorCodeType], [DeadlineFactorCodeSubtype], [DeadlineFactorCode])
GO
