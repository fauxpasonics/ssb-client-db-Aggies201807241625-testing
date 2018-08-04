CREATE TABLE [ods].[PAC_auditrecords]
(
[Seq] [bigint] NOT NULL,
[DbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[id] [uniqueidentifier] NOT NULL,
[ChannelID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[orgnizationId] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[processid] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordkey] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[changetype] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subtype] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attributekey] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[originalvalvue] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[newvalue] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_auditrecords] ON [ods].[PAC_auditrecords]
GO
