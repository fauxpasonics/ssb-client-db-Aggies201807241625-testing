SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [rpt].[rpt_PickListCategory] as

select distinct
	categoryname
From ods.VTXCategory
where categorytypeid = 2
GO
