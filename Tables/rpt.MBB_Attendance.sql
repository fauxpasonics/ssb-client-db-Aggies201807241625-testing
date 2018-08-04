CREATE TABLE [rpt].[MBB_Attendance]
(
[season] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventstartdate] [datetime2] (6) NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opponent] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attend] [int] NULL,
[pricecodegroup] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pricecodesorting] [int] NULL
)
GO
