CREATE TABLE [ods].[PAC_ScheduledPaymentAllocation]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PaymentScheduleID] [bigint] NOT NULL,
[ScheduledPaymentID] [int] NOT NULL,
[Sequence] [int] NOT NULL,
[AllocationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RolledPaymentScheduleID] [bigint] NULL,
[DriveYear] [int] NULL,
[ApplyAmount] [money] NULL,
[PaidOffAmount] [money] NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_ScheduledPaymentAllocation] ON [ods].[PAC_ScheduledPaymentAllocation]
GO
