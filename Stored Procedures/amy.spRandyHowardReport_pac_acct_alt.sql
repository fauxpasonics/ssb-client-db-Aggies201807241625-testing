SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[spRandyHowardReport] '3/31/2017', '03/31/2017','2017'
--minus
--exec [amy].[spRandyHowardReport_pac_acct]  '3/31/2017', '03/31/2017','2017'
create PROCEDURE [amy].[spRandyHowardReport_pac_acct_alt]
(
	@start_date1	varchar(20)  = '03/31/2017',
	@end_date1	varchar(20)  = '03/31/2017',
	@trans_year	char(4) = '2017'
)
AS
/*
	TRUNCATE TABLE t_RandyHowardReport

	INSERT INTO t_RandyHowardReport
	(	Allocation,
		LevelName,
		TotalDonors,
		TotalPledges,
		TotalReceipts
	)  */
 -- select  --* from t_RandyHowardReport
 begin
 
 declare @tixeventlookupid varchar(50)
declare @start_date date
 declare @end_date datetime
 
 set @tixeventlookupid   = (select tixeventlookupid  from amy.PriorityEvents where sporttype = 'FB' and ticketyear = @trans_year);
set	@start_date = @start_date1;
 set	@end_date	 =  cast(@end_date1 + ' 23:59:59' as datetime);
 --set	@trans_year	 = '2017';
  
  with percenttb as (select tt.adnumber, 
  round(case when  annual_expected-isnull( creditapplied, 0)  <= 0 or premium_annual_expected-isnull( creditapplied, 0) <=0 then 0 
else   ( premium_annual_expected-isnull( creditapplied, 0))  /( annual_expected-isnull( creditapplied, 0) ) end,2)  premium_annual_expected_pct,
round(case when  annual_expected-isnull( creditapplied, 0)  > 0 and premium_annual_expected-isnull( creditapplied, 0) >0 then  
  nonpremium_annual_expected / ( annual_expected-isnull( creditapplied, 0) )  
  when premium_annual_expected-isnull( creditapplied, 0) <=0 then 1 else 0 end,2)  non_premium_annual_expected_pct
--round(case when  annual_expected  = 0 then 0 else  premium_annual_expected / annual_expected end,2)  premium_annual_expected_pct,
--round(case when  annual_expected  = 0 then 0 else   nonpremium_annual_expected / annual_expected  end,2)   non_premium_annual_expected_pct
from (
select accountnumber adnumber, 
sum( py.Annual) annual_expected, 
sum(case when sa.premium_ind = 1 then  py.Annual else 0 end) premium_annual_expected, 
sum(case when isnull(sa.premium_ind,0) = 0 then  py.Annual else 0 end) nonpremium_annual_expected 
  from  amy.seatdetail_individual_history  ct  
  left join seatarea sa on ct.seatareaid = sa.seatareaid
       left join amy.playbookpricegroupseatarea   py on  ct.seatareaid = py.seatareaid and py.pricecodecode = ct.seatpricecode  and
      py.sporttype =  'FB'  and py.ticketyear =  cast( 	@trans_year as int)
           where  ct.tixeventlookupid =  @tixeventlookupid
          and cancel_ind is null   and 
          isnull(seatingtype,'') <> 'Suite'
          group by accountnumber ) tt  
          left join  ( 
       --   select adnumber, sum(transamount) creditapplied from advcontact c,        advcontacttransheader h
       --   , advcontacttranslineitems l where c.contactid = h.contactid and  h.transid = l.transid and transyear = @trans_year  and transtype = 'Credit' and programid = 678      
       --   group by adnumber
        select acct adnumber, sum(CreditAmt) creditapplied from PacTranItem_alt_vw where driveyear = @trans_year and  allocationid in  ('FEC')
        group by acct
       --   , advcontacttranslineitems l where c.contactid = h.contactid and  h.transid = l.transid and transyear = @trans_year  and transtype = 'Credit' and programid = 678      
       --   group by adnumber       
          ) Credit on tt.adnumber = credit.adnumber collate DATABASE_DEFAULT
    --   select * from advprogram where programid = 678  --FEC, FEC-ST
    --   select * from a
       )  
       select a.*,  pglmap.GL, pglmap.R, pglmap.Fd, pglmap.CC from (
	SELECT 	Allocation,   acct,
	--	LevelName, 
		--0,
		SUM(TotalPledges) AS TotalPledges, 
		SUM(TotalReceipts) AS TotalReceipts,
  SUM(TotalPledges_premium) as TotalPledges_premium ,
  SUM(TotalPledges_nonpremium)as TotalPledges_nonpremium  ,
  SUM(TotalReceipts_premium) as TotalReceipts_premium ,
  SUM(TotalReceipts_nonpremium ) as TotalReceipts_nonpremium   --into t_RandyHowardReport
  , programid
	 from ( 
		SELECT 	case when fundtypecode = 'M' then p.MATCHACCT  else p.acct end acct,
			allocationid ProgramID, 
			null LevelName,
			p.allocationname   Allocation,  
			SUM(p.MatchingPledgeAmt+ p.PledgeAmt ) AS TotalPledges,
			SUM(0) AS TotalReceipts,
      SUM(CASE when allocationid = 'FSC' THEN p.PledgeAmt * ISNULL(premium_annual_expected_pct ,1) + p.MatchingPledgeAmt*ISNULL(premium_annual_expected_pct,1)
         --  when MatchingPledgeAmt<> 0  and  allocationid = 'FSC'  then p.MatchingPledgeAmt*ISNULL(premium_annual_expected_pct,1)
           else 0 END) AS TotalPledges_premium,
      SUM(CASE  when  allocationid = 'FSC'  THEN (p.PledgeAmt + p.MatchingPledgeAmt) - ((p.PledgeAmt + p.MatchingPledgeAmt)* ISNULL(premium_annual_expected_pct ,1)) 
        --  when MatchingGift=1  and l.programid = 674 then MatchAmount - ( MatchAmount*ISNULL(premium_annual_expected_pct,1) )
         else 0 END)  AS TotalPledges_nonpremium,
      SUM(0) AS TotalReceipts_premium,
      SUM(0) AS TotalReceipts_nonpremium   
  from amy.PacTranItem_alt_vw p  
      --FROM 	advContactTransHeader h  
		--	JOIN advContactTransLineItems l ON h.TransID = l.TransID
		--	JOIN advProgram p ON l.ProgramID = p.ProgramID
    --  left join advcontact c on c.contactid = h.contactid   
      left join  percenttb on case when fundtypecode = 'M' then p.MATCHACCT  else p.acct end = percenttb.adnumber
		WHERE 	ReceivedDate BETWEEN @start_date AND @end_date   and fundtypecode in ('S','M')
    -- AND TransType = 'Cash Pledge'
		GROUP 	BY case when fundtypecode = 'M' then p.MATCHACCT  else p.acct end ,  p.allocationID, p.AllocationName 
		UNION
		SELECT 	
     case when fundtypecode = 'M' then p.MATCHACCT  else p.acct end acct, 
			p.allocationID ProgramID, 
			null LevelName,
			p.AllocationName Allocation, 
			SUM(0) AS TotalPledes,
			SUM( PaymentAmt + MatchingPaymentAmt) AS TotalReceipts,
      SUM(0) AS TotalPledges_premium,
      SUM(0) AS TotalPledges_nonpremium,
      SUM(CASE when allocationid = 'FSC' and fundtypecode = 'S' THEN PaymentAmt*ISNULL(premium_annual_expected_pct ,1)  
               when allocationid = 'FSC' and fundtypecode = 'M' then MatchingPaymentAmt*ISNULL(premium_annual_expected_pct ,1) else 0 END) AS TotalReceipts_premium,
      SUM(CASE when allocationid = 'FSC' and fundtypecode = 'S' THEN PaymentAmt - PaymentAmt *ISNULL(premium_annual_expected_pct ,1) 
               when allocationid = 'FSC' and fundtypecode = 'M' then MatchingPaymentAmt - MatchingPaymentAmt*ISNULL(premium_annual_expected_pct ,1) else 0 END) AS TotalReceipts_nonpremium
	 from amy.PacTranItem_alt_vw p
  --advContactTransHeader h
	--		JOIN advContactTransLineItems l ON h.TransID = l.TransID
	--		JOIN advProgram p ON l.ProgramID = p.ProgramID
  --    left join 	advcontact c on c.contactid = h.contactid
      left join 
  /*(select adnumber, 
round(case when  annual_expected  = 0 then 0 else  premium_annual_expected / annual_expected end,2)  premium_annual_expected_pct,
round(case when  annual_expected  = 0 then 0 else   nonpremium_annual_expected / annual_expected  end,2)   non_premium_annual_expected_pct  from (
select accountnumber adnumber, 
sum( py.Annual) annual_expected, 
sum(case when sa.premium_ind = 1 then  py.Annual else 0 end) premium_annual_expected, 
sum(case when isnull(sa.premium_ind,0) = 0 then  py.Annual else 0 end) nonpremium_annual_expected 
  from  amy.seatdetail_individual_history  ct  
  left join seatarea sa on ct.seatareaid = sa.seatareaid
       left join amy.playbookpricegroupseatarea   py on  ct.seatareaid = py.seatareaid and py.pricecodecode = ct.seatpricecode  and
      py.sporttype =  'FB'  and py.ticketyear = 2017
           where  ct.tixeventlookupid =  'F17-Season'
          and cancel_ind is null   and 
          isnull(seatingtype,'') <> 'Suite'
          group by accountnumber ) tt) */
          percenttb on case when fundtypecode = 'M' then p.MATCHACCT  else p.acct end = percenttb.adnumber
		/*	LEFT JOIN 
			(	SELECT DISTINCT ContactID, ProgramID, LevelName
				FROM 	advContactMembershipLevels cl
					JOIN advMembership m ON cl.MembID = m.MembID
					JOIN advMembershipLevels ml ON cl.PledgeLevel = ml.LevelID 
					JOIN advAllocationLevels al ON ml.MembID = al.MembID
				WHERE 	m.TransYear = @trans_year AND m.MembershipName = 'Football'
			) m ON h.ContactID = m.ContactID AND l.ProgramID = m.ProgramID */
		WHERE 	ReceivedDate BETWEEN @start_date AND @end_date  and fundtypecode in ('S','M')
   -- TransType IN ('Cash Receipt', 'CR Correction') AND ISNULL(PaymentType, '') <> 'NG Credit'
		GROUP 	BY case when fundtypecode = 'M' then p.MATCHACCT  else p.acct end, p.allocationID, p.AllocationName 
	) x  -- where programid = 674
	GROUP BY Allocation, LevelName, programid, acct) a
  left join ProgramGLMappings pglmap on a.programid = pglmap.allocationid collate database_default
 	ORDER BY Allocation
  end
--RETURN
GO
