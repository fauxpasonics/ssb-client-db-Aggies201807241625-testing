SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_SeatUP2]
AS
declare @percentdue numeric(10, 0)
declare @seatdetail_individual_history_id int  


declare tixcursor CURSOR LOCAL FAST_FORWARD FOR  
select * from  ( select
(select percentdue from capital_percent where adnumber = ct.accountnumber and seatregionid = ks.SeatRegionID) percentdue,
ct.seatdetail_individual_history_id
  from  amy.seatdetail_individual_history  ct,  amy.VenueSectionsbyyear  ks ,          amy.SeatRegion sr
          where  ct.tixeventlookupid =  'F16-Season'  and
          ks.sporttype     =  'FB' 
          and ct.seatsection      = ks.sectionnum and ct.year between ks.startyear and endyear
          and ((ks.rows is not null and ks.rows like '%;'+cast(ct.seatrow as varchar) +';%' )   or (ks.rows is null) )
          and sr.seatregionid= ks.seatregionid 
          ) ff where percentdue is not null

begin 

         OPEN tixCursor
         FETCH NEXT FROM TixCursor
              INTO  @percentdue  ,  @seatdetail_individual_history_id             
   
         WHILE @@FETCH_STATUS = 0
         BEGIN           
             update amy.seatdetail_individual_history  set  CAP_Percent_Owe_ToDate = @percentdue  where seatdetail_individual_history_id =  @seatdetail_individual_history_id
	       END   
         
         FETCH NEXT FROM TixCursor INTO @percentdue  ,  @seatdetail_individual_history_id         
             

  close tixCursor  
  
end
GO
