CREATE TABLE [ods].[PAC_SpecialEvent]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[SpecialEventID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[DonorCategoryID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DriveYear] [int] NULL,
[EmailConfirmationTemplateID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EventDate] [datetime] NULL,
[EventTime] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Image] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCommentAllowed] [bit] NULL,
[IsLoginRequired] [bit] NULL,
[Location] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RsvpDeadline] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecialEventCategoryID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_SpecialEvent] ON [ods].[PAC_SpecialEvent]
GO
