SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_Renewal_Dashboard_Changes_Location] (@sporttype varchar(20) = 'BB-MB',  @ticketyear varchar(4)= '2016' )
AS

Declare @tixeventlookupid varchar(50)
Declare @relocateproductid  int
Declare @renewalcategory varchar(20)
Declare @cancelproductid  int
Declare @tixeventtitleshort varchar(40)


--set @tixeventlookupid = (select tixeventlookupid from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear);
select @tixeventlookupid = tixeventlookupid , @relocateproductid = relocateproductid, @cancelproductid = cancelproductid ,@renewalcategory = renewalcategory, @tixeventtitleshort = tixeventtitleshort
from amy.PriorityEvents pe1 where sporttype = @sporttype and ticketyear = @ticketyear

select * from  ( 
   select max(case when seatchange = 'Relocate Seats' then seatcount else 0 end ) "Relocate Seats",
          max(case when seatchange = 'Release Seats' then seatcount else 0  end) "Release Seats"
        from (
           select SeatChange, count(acct ) seatcount  from            
           (select case when product_id  = @relocateproductid then 'Relocate Seats' 
           when product_id = @cancelproductid then 'Release Seats'
           else null end SeatChange,  o.acct          
           from ADVEvents_tbl_order_line l
           LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
           WHERE o.category = @renewalcategory  and renewal_descr not like    '%SRO%'
           AND submit_date IS NOT NULL
           and   product_id in (@cancelproductid, @relocateproductid )
           ) SeatChange 
          group by SeatChange ) sum1  ) y1 where   "Relocate Seats"  is not null
GO
