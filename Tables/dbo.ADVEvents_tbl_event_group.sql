CREATE TABLE [dbo].[ADVEvents_tbl_event_group]
(
[id] [int] NOT NULL,
[title] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[descr] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[register_deadline] [datetime] NULL,
[programid] [int] NOT NULL,
[confirm_info] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sort_order] [int] NOT NULL,
[accept_payment_plan] [bit] NOT NULL,
[total_due_on] [datetime] NULL,
[terms_and_conditions] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirm_thank] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[summary_info] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [bit] NOT NULL,
[regrets] [bit] NOT NULL,
[regrets_info] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
