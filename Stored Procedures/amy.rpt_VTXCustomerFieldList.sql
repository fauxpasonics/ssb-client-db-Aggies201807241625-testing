SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_VTXCustomerFieldList] as
select  name +' (' + cast( id as varchar) + ')' customerfieldid, name customerfieldname from  ods.VTXcustomerfields cf where visible = 1 and etl_isDeleted is null
and id in (select distinct customerfieldid from ods.VTXcustomerfielddata )
order by  name
GO
