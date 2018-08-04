SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[playbook_pricegrouppricecodes] as 
select  sporttype, TicketYear, (select pricegroupname from pricegroup t where t.pricegroupid = y.PriceGroupID ) pricegroupname,  pricecodecode, pricegroupid, pricecodeid
from pricecodebyyear  y
GO
