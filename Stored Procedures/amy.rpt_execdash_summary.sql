SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_execdash_summary] as
select y.reportyear, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'Annual' then y.ReceiptAmount else 0 end),1) AnnualReceiptAmount, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'Annual' then y.YTDReceiptAmount else 0 end),1)  AnnualYTDReceiptAmount, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'Annual' then y.PledgeAmount else 0 end),1)  AnnualPledgeAmount, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'Annual' then y.YTDPledgeAmount else 0 end ),1)  AnnualYTDPledgeAmount ,
'$' + convert(VARCHAR,sum(case when y.GivingType = 'CAP' then y.ReceiptAmount else 0 end ),1) CAPReceiptAmount, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'CAP' then y.YTDReceiptAmount else 0 end ),1) CAPYTDReceiptAmount, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'CAP' then y.PledgeAmount else 0 end),1)  CAPPledgeAmount, 
'$' + convert(VARCHAR,sum(case when y.GivingType = 'CAP' then y.YTDPledgeAmount else 0 end ),1)  CAPYTDPledgeAmount 
from rpt_execdash_summary_vw  y where cast(reportyear as varchar) = cast(year(getdate()) as varchar)
group by y.reportyear
GO
