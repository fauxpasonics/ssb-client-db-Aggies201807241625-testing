SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [rpt].[rpt_DonorProfileEventsCurrent] (@ADNumber NVARCHAR(200))

AS 

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

select 
	ei.start_date Date
	, sum(qty) QTY
	,REPLACE( replace(ei.title, '<br />', ' '), '<br>', ' ') longtitle
from dbo.ADVEvents_tbl_event_group eg
JOIN dbo.ADVEvents_tbl_event_item ei
	ON eg.id = ei.event_group_id 
JOIN dbo.ADVEvents_tbl_order_line ol
	ON ei.id = ol.event_item_id
JOIN dbo.ADVEvents_tbl_order o 
	ON o.id = ol.order_id
WHERE submit_date is not null
AND o.acct = @ADNumber
AND DATEPART(yyyy,ei.start_date) = @CurrentYear
GROUP BY 
	o.acct
	,start_date
	,replace( replace(ei.title, '<br />', ' '), '<br>', ' ')
ORDER BY start_date desc
GO
