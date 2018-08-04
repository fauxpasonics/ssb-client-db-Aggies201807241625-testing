CREATE TABLE [ods].[PAC_ScheduledPaymentReceipt]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ProcessID] [uniqueidentifier] NOT NULL,
[ScheduledPaymentReceiptID] [int] NOT NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllocationID] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Allocation] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchID] [bigint] NULL,
[IsBatchAutoCreated] [bit] NULL,
[ScheduledPaymentID] [int] NULL,
[DriveYear] [int] NULL,
[TransactionID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PatronAccount] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentDate] [date] NULL,
[AmountDue] [money] NULL,
[EmailAddress] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ErrorMessage] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayCode] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PaymentScheduleID] [bigint] NULL,
[PaymentStatusCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PaymentStatusCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PaymentStatusCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[PaymentStatusCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ReasonCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_ScheduledPaymentReceipt] ON [ods].[PAC_ScheduledPaymentReceipt]
GO
