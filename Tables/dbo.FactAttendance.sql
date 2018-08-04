CREATE TABLE [dbo].[FactAttendance]
(
[FactAttendanceId] [bigint] NOT NULL,
[DimEventId] [int] NOT NULL,
[DimCustomerId] [bigint] NOT NULL,
[DimSeatId] [int] NOT NULL,
[ScanDateTime] [datetime] NULL,
[ScanGate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Barcode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Channel] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSID_event_id] [int] NOT NULL,
[SSID_acct_id] [int] NULL,
[SSID_section_id] [int] NOT NULL,
[SSID_row_id] [int] NOT NULL,
[SSID_seat] [int] NOT NULL,
[ETL_SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_CreatedDate] [datetime] NULL,
[ETL_UpdatedDate] [datetime] NULL
)
GO
ALTER TABLE [dbo].[FactAttendance] ADD CONSTRAINT [PK_FactAttendance] PRIMARY KEY CLUSTERED  ([FactAttendanceId])
GO
