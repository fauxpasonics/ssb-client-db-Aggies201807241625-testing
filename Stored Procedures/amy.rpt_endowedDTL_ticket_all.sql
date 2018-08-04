SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_endowedDTL_ticket_all] 
as 
declare @ticketyear  varchar(4)
declare @accountlist nvarchar(MAX)

set @ticketyear = cast(year(getdate()) as varchar)


select @accountlist = stuff(( select distinct ', ' + cast( adnumber as varchar) from endowedsetup as p2 for xml path('') ), 1, 1, '')

exec [amy].[rpt_SeatDetail_by_event]   'FB',@ticketyear,2,@accountlist
GO
