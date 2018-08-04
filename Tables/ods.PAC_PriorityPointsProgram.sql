CREATE TABLE [ods].[PAC_PriorityPointsProgram]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PriorityPointsProgramID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountQualification] [int] NULL,
[CalculateRank] [bit] NULL,
[ContributingAllocationSetID] [uniqueidentifier] NULL,
[DriveYear] [int] NULL,
[InternalNotes] [nvarchar] (999) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsMinimumAmountRequired] [bit] NULL,
[MinimumGivingAmount] [money] NULL,
[RoundToOptionCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RoundToOptionCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RoundToOptionCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RoundToOptionCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_PriorityPointsProgram] ON [ods].[PAC_PriorityPointsProgram]
GO
