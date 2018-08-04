SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportRegionReconReportTypeList]
as
select 3 ReportType, 'All Tickets/Donations'  ReportValue,'NO FILTER' FilterDesc
union 
select 1 ReportType, 'CAP/Annual Pledge Differences'  ReportValue,'(CAP Expected - Cap Pledges(Reg/Match) - Credit) OR (Annual Expected - Annual Pledges (Reg/Match) - Credit)'  FilterDesc
union 
select 2 ReportType, 'Balance Due'  ReportValue,'CAP Expected(To Date) - (CAP Receipts (Reg/Match)+ CAP Credits) > 0 OR (Annual Expected - Reg Receipts- Match Pledge - Credits - Scheduled Payments) > 0'  FilterDesc
union 
select 4 ReportType, 'Annual Paid'  ReportValue,'(Annual Expected  - Reg Receipts - Match Pledge - Annual Credit - Scheduled Payments) <= 0 and Annual Renewal Date is not empty'  FilterDesc
union 
select 6 ReportType, 'Annual Receipts > Pledges'  ReportValue,'Reg Receipt > Reg Pledge or Match Receipt > Match Pledge '  FilterDesc
union 
select 7 ReportType, 'CAP Receipts > Pledges'  ReportValue,'CAP Reg Receipt > CAP Reg Pledge or CAP Match Receipt > CAP Match Pledge '  FilterDesc
union 
select 5 ReportType, 'Capital Due'  ReportValue,'Adv Adjusted Pledge - Receipts (Reg/Match) - Credits'  FilterDesc
GO
