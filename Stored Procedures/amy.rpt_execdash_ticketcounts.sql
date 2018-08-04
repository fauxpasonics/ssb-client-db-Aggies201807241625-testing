SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_ticketcounts] as
select pe.sporttype,   --k.tixeventlookupid ,
k.[year]  reportyear,   sum(qty) Quantity from seatdetail_flat k, PriorityEvents pe
where pe.tixeventlookupid = k.tixeventlookupid
group by pe.sporttype,   -- k.tixeventlookupid ,
k.[year] 
order by sporttype , reportyear
GO
