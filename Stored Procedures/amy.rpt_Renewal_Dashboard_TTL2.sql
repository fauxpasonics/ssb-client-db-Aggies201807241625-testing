SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_Renewal_Dashboard_TTL2] (@sporttype varchar(20) = 'BB-MB', 
 @ticketyear varchar(4)= '2016'
 )
AS

Declare @tixeventlookupid varchar(50)

set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);

select  'Add Ons' RequestType  , sum(addedItems) Quantity from  amy.rpt_seatrecon_tb  t where  sporttype = @sporttype and ticketyear = @ticketyear and addeditems >0
union all
 select  'New Items' RequestType  , sum(newitems) Quantity from  amy.rpt_seatrecon_tb  t where  sporttype = @sporttype and ticketyear = @ticketyear and newitems >0
GO
