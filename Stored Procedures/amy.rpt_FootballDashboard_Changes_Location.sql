SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure [amy].[rpt_FootballDashboard_Changes_Location] as

declare @currentseason char(4)

set @currentseason = (select max(currentseason) from advcurrentyear)

 select         isnull(  sectiongroup , 'Relocation')  sectiongroup , max(case when seatchange = 'Relocate Seats' then seatcount else 0 end ) "Relocate Seats",
        max(case when seatchange = 'Release Seats' then seatcount else 0  end) "Release Seats"
        from (
           select SeatChange,  sr.sectiongroup , count(acct ) seatcount   from (
          --  select * from (
           select   renewal_descr, seatchange, acct, seatsection, seatrow from            
           ( 
       --  SUBSTRING(substring(renewal_descr, charindex(':',renewal_descr )+1,20), 1,  ( charindex(':', substring(renewal_descr,  charindex(':',renewal_descr )+1,20) ) )   -1)    SEATROW     
       --    SUBSTRING(substring(renewal_descr, charindex(':',renewal_descr )+1,20),1, charindex(':',substring(renewal_descr, charindex(':',renewal_descr )+1,20))-1)   SEATROW
     select  renewal_descr, 
     case when  product_id = 100 then 'Relocate Seats' 
           when product_id = 98 then 'Release Seats'
           else null end SeatChange,  o.acct   ,
          replace(substring(replace(renewal_descr,  @currentseason + ' Football Season(','' ),1, charindex(':',replace(renewal_descr,  @currentseason + ' Football Season(','' ))),':','') seatsection, 
          replace(   SUBSTRING(  
                         substring(renewal_descr,
                                charindex(':',renewal_descr )
                                +1,
                                20
                                ),
                      1,  
                        (
                           charindex(':', 
                                     substring(renewal_descr,  
                                               charindex(':', renewal_descr )
                                               +1,
                                               20
                                                ) 
                                    ) 
                          )  ---  -1
                      ) , ':','')   seatrow
           from ADVEvents_tbl_order_line l
           LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
           WHERE o.category = @currentseason +'FB' and renewal_descr not like    '%SRO%'
           AND submit_date IS NOT NULL
           and  product_id in (98 --,100
           )
           ) x
           union
            select null  renewal_descr, 
           'Relocate Seats'  SeatChange,  accountnumber  ,
           seatsection, 
           seatrow
              from seatdetail_individual_history where tixeventlookupid = 'F18-Season' and cancel_ind is null and seatpricecode not like '%SRO%' and accountnumber in
           ( select acct     from ADVEvents_tbl_order_line l
           LEFT JOIN ADVEvents_tbl_order o ON o.id = l.order_id
           WHERE o.category = '2018'+'FB' and renewal_descr not like    '%SRO%'
           AND submit_date IS NOT NULL
           and  product_id in (100 ))
           ) SeatChange 
               left join  amy.VenueSectionsbyyear  ks   on     ks.sporttype     =  'FB'    
          and seatchange.seatsection      = ks.sectionnum and @currentseason between ks.startyear and ks.endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(Seatchange.seatrow as varchar) +';%' )   or (ks.rows is null) )        
          left join       amy.SeatRegion sr on sr.seatregionid= ks.seatregionid 
          group by SeatChange,  sr.sectiongroup
          ) sum1 
            group by   isnull(  sectiongroup , 'Relocation')
GO
