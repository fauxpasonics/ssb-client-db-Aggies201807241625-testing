SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec [amy].[spRandyHowardReport] '3/31/2017', '03/31/2017','2017'
CREATE PROCEDURE [amy].[spRandyHowardReport]
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
 declare @end_date date
 
 set @tixeventlookupid   = (select tixeventlookupid  from amy.PriorityEvents where sporttype = 'FB' and ticketyear = @trans_year);
set	@start_date = @start_date1;
 set	@end_date	 = @end_date1;
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
          group by accountnumber ) tt  left join  (     select adnumber, sum(transamount) creditapplied from advcontact c, 
       advcontacttransheader h
       , advcontacttranslineitems l where c.contactid = h.contactid and  h.transid = l.transid and transyear = @trans_year 
       and transtype = 'Credit' and programid = 678
       group by adnumber) Credit on tt.adnumber = credit.adnumber)  
       select a.*,  pglmap.GL, pglmap.R, pglmap.Fd, pglmap.CC from (
	SELECT 	Allocation,  
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
		SELECT 	h.ContactID,
			l.ProgramID, 
			null LevelName,
			 p.ProgramName  Allocation,  
			SUM(CASE MatchingGift WHEN 0 THEN TransAmount ELSE MatchAmount END) AS TotalPledges,
			SUM(0) AS TotalReceipts,
   SUM(CASE when  MatchingGift=0  and l.programid = 674  THEN TransAmount* ISNULL(premium_annual_expected_pct ,1)
            when MatchingGift=1  and l.programid = 674 then MatchAmount*ISNULL(premium_annual_expected_pct,1)
            else 0 END) AS TotalPledges_premium,
      SUM(CASE  when MatchingGift=0 and l.programid = 674 THEN TransAmount - ( TransAmount* ISNULL(premium_annual_expected_pct ,1)) when MatchingGift=1  and l.programid = 674 then MatchAmount - ( MatchAmount*ISNULL(premium_annual_expected_pct,1) ) else 0 END) AS TotalPledges_nonpremium,
        SUM(0) AS TotalReceipts_premium,
      SUM(0) AS TotalReceipts_nonpremium       
		FROM 	advContactTransHeader h  
			JOIN advContactTransLineItems l ON h.TransID = l.TransID
			JOIN advProgram p ON l.ProgramID = p.ProgramID
      left join advcontact c on c.contactid = h.contactid
      left join  percenttb on c.adnumber = percenttb.adnumber
			/*LEFT JOIN 
			(	SELECT DISTINCT ContactID, ProgramID, LevelName
				FROM 	advContactMembershipLevels cl
					JOIN advMembership m ON cl.MembID = m.MembID
					JOIN advMembershipLevels ml ON cl.PledgeLevel = ml.LevelID 
					JOIN advAllocationLevels al ON ml.MembID = al.MembID
				WHERE 	m.TransYear = @trans_year AND m.MembershipName = 'Football'
			) m ON h.ContactID = m.ContactID AND l.ProgramID = m.ProgramID */
		WHERE 	TransDate BETWEEN @start_date AND @end_date AND TransType = 'Cash Pledge'
		GROUP 	BY h.ContactID, l.ProgramID, p.ProgramName 
		UNION
		SELECT 	h.ContactID, 
			l.ProgramID, 
			null LevelName,
			 p.ProgramName  Allocation, 
			SUM(0) AS TotalPledes,
			SUM(CASE MatchingGift WHEN 0 THEN TransAmount ELSE MatchAmount END) AS TotalReceipts,
     SUM(0) AS TotalPledges_premium,
      SUM(0) AS TotalPledges_nonpremium,
    SUM(CASE  when MatchingGift =0 and l.programid = 674 THEN TransAmount*ISNULL(premium_annual_expected_pct ,1)  when MatchingGift=1  and l.programid = 674 then MatchAmount*ISNULL(premium_annual_expected_pct ,1) else 0 END) AS TotalReceipts_premium,
      SUM(CASE when MatchingGift =0  and l.programid = 674 THEN TransAmount - TransAmount*ISNULL(premium_annual_expected_pct ,1)  when MatchingGift=1  and l.programid = 674 then MatchAmount - MatchAmount*ISNULL(premium_annual_expected_pct ,1) else 0 END) AS TotalReceipts_nonpremium
		FROM  advContactTransHeader h
			JOIN advContactTransLineItems l ON h.TransID = l.TransID
			JOIN advProgram p ON l.ProgramID = p.ProgramID
      left join 	advcontact c on c.contactid = h.contactid
      left join /*(select adnumber, 
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
          percenttb on c.adnumber = percenttb.adnumber
		/*	LEFT JOIN 
			(	SELECT DISTINCT ContactID, ProgramID, LevelName
				FROM 	advContactMembershipLevels cl
					JOIN advMembership m ON cl.MembID = m.MembID
					JOIN advMembershipLevels ml ON cl.PledgeLevel = ml.LevelID 
					JOIN advAllocationLevels al ON ml.MembID = al.MembID
				WHERE 	m.TransYear = @trans_year AND m.MembershipName = 'Football'
			) m ON h.ContactID = m.ContactID AND l.ProgramID = m.ProgramID */
		WHERE 	TransDate BETWEEN @start_date AND @end_date AND TransType IN ('Cash Receipt', 'CR Correction') AND ISNULL(PaymentType, '') <> 'NG Credit'
		GROUP 	BY h.ContactID, l.ProgramID,  p.ProgramName 
	) x  -- where programid = 674
	GROUP BY Allocation, LevelName, programid) a
  left join ProgramGLMappings pglmap on a.programid = pglmap.programid
 	ORDER BY Allocation
  end
--RETURN
GO
