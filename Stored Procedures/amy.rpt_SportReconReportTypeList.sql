SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SportReconReportTypeList]
as
select 3 ReportType, 'All Tickets/Donations' ReportValue
union 
select 1 ReportType, 'CAP/Annual Pledge Differences' ReportValue
union 
select 2 ReportType, 'Balance Due' ReportValue
--union 
--select 4 ReportType, 'Annual Paid' ReportValue
--union 
select 6 ReportType, 'Annual Receipts Higher than Pledges' ReportValue
union 
select 7 ReportType, 'CAP Receipts Higher than Pledges' ReportValue
--union 
--select 5 ReportType, 'Capital Due (Football Recon Only)' ReportValue
GO
