SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   procedure [amy].[rpt_execdash_ticket_summary_last_year] as
select rptyear reportyear, 
 '$' + convert(VARCHAR,sum(cast(y.ordergrouptotalpaymentscleared as money) ),1) OrdersClearedAmount, 
 '$' + convert(VARCHAR,sum(cast(y.ordergroupbottomlinegrandtotal as money)),1 ) OrderDueAmount, 
 '$' + convert(VARCHAR,sum(cast(y.ordergrouptotalpaymentsonhold  as money)),1)  OnholdAmount, 
 '$' + convert(VARCHAR,sum(cast(y.ordergrouppaymentbalance as money) ),1)  BalanceAmount ,
 '$' + convert(VARCHAR,sum(cast(y.YTDordergrouptotalpaymentscleared as money) ),1) YTDOrdersClearedAmount
from rpt_execdash_ticket_summary_tb   y where rptyear = year(getdate())-1
group by y.rptyear
GO
