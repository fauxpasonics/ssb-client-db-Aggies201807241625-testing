SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [amy].[GetPreviousSportDonationsPledgesCredits]
  (@sporttype varchar(20) = 'FB', @ticketyear varchar(4)= '2017',  @adnumber integer = 600386)
RETURNS TABLE
AS
RETURN

select  case when salloc.programname like '%Suite%' and sporttype = 'FB' then 'Suite' else 'Regular' end seattype,
salloc.sporttype,   -- programtypecode,--seatregionid,
 adnumber, h.contactid, --receiptid,
  -- min (case when  SAlloc.ProgramTypeName = 'Annual' and transtype = 'Cash Receipt' then transdate else null end) min_annual_receipt_date,
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Pledge%'   THEN isnull(l.TransAmount,0) + isnull(l.matchamount,0)  ELSE 0 END) annual_pledge_amount,   
   sum (CASE WHEN  SAlloc.ProgramTypeCode = 'Annual' AND transtype LIKE '%Receipt%' THEN  isnull(l.TransAmount,0) + isnull(l.matchamount,0) ELSE 0 END) annual_receipt_amount,   
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Annual Credit%') or (SAlloc.ProgramTypeName LIKE 'Annual' and transtype = 'Credit') THEN  isnull(l.transamount,0)+ isnull(l.matchamount,0)  ELSE    0   END)  annual_credit_amount,
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Pledge%'   THEN  isnull(l.TransAmount,0) + isnull(l.matchamount,0) ELSE 0 END) capital_pledge_amount,  
   sum (CASE WHEN  SAlloc.ProgramTypeName = 'Capital' AND transtype LIKE '%Receipt%'  THEN  isnull(l.TransAmount,0) + isnull(l.matchamount,0) ELSE 0 END) capital_receipt_amount,    
   sum (CASE WHEN (SAlloc.ProgramTypeName LIKE '%Capital Credit%' ) or (SAlloc.ProgramTypeName ='Capital' and transtype = 'Credit') THEN   isnull(l.transamount,0)+ isnull(l.matchamount,0)  ELSE  0  END) capital_credit_amount
 FROM advcontact c,advcontacttransheader h, advcontacttranslineitems l, --advProgram p,
 (select  distinct
 salloc1.sporttype, --  seatregionid, 
 programid , ProgramTypeName, programtypecode  , programname
 from  --amy.SeatArea Sarea, 
  amy.SeatAllocation SAlloc1  ---with suites this is an issue since seatareas map to same seatallocation
         WHERE     -- Sarea.SeatAreaID = SAlloc1.SeatAreaID and 
         salloc1.sporttype =  @sporttype and isnull(salloc1.inactive_ind,0) =0 ) salloc 
where l.ProgramID = SAlloc.ProgramID
AND c.contactid = h.contactid
AND h.TransID = l.TransID
AND transyear IN ( @ticketyear,'CAP')
and (matchinggift = 0 or matchinggift is null)
and adnumber = @adnumber
group by salloc.sporttype, c.adnumber,h.contactid, -- , programtypecode
case when salloc.programname like '%Suite%' and sporttype = 'FB' then 'Suite' else 'Regular' end 
having sum( isnull(l.transamount,0)+ isnull(l.matchamount,0)) <> 0
GO
