CREATE TABLE [dbo].[ADVQA_adv_contactdonorcategories]
(
[ContactID] [int] NOT NULL,
[CategoryID] [int] NOT NULL,
[Value] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NOT NULL,
[CreateUser] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
