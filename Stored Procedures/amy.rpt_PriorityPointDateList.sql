SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_PriorityPointDateList]
as

select  convert(varchar,entrydate,107) MemberYear, convert(varchar ,entrydate,21) exactdatetime from 
(select distinct entrydate
FROM advhistoricalprioritypoints DGY 
where entrydate> getdate()-365) t
order by entrydate desc
GO
