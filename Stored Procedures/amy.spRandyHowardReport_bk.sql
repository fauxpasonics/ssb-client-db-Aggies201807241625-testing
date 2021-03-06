SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create  PROCEDURE [amy].[spRandyHowardReport_bk]
(
	@start_date	DATETIME,
	@end_date	DATETIME,
	@trans_year	char(4)
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
  
	SELECT 	transdate, Allocation, 
	--	LevelName, 
		--0,
		SUM(TotalPledges) AS TotalPledges, 
		SUM(TotalReceipts) AS TotalReceipts,
  SUM(TotalPledges_premium) as TotalPledges_premium ,
  SUM(TotalPledges_nonpremium)as TotalPledges_nonpremium  ,
  SUM(TotalReceipts_premium) as TotalReceipts_premium ,
  SUM(TotalReceipts_nonpremium ) as TotalReceipts_nonpremium   --into t_RandyHowardReport
	 from ( 
		SELECT 	h.ContactID,
			l.ProgramID, 
			null LevelName,
			 p.ProgramName  Allocation,  transdate,
			SUM(CASE MatchingGift WHEN 0 THEN TransAmount ELSE MatchAmount END) AS TotalPledges,
			SUM(0) AS TotalReceipts,
   SUM(CASE when  MatchingGift=0  and l.programid = 674  THEN TransAmount* ISNULL(premium_annual_expected_pct ,1)
            when MatchingGift=1  and l.programid = 674 then MatchAmount*ISNULL(premium_annual_expected_pct,1)
            else 0 END) AS TotalPledges_premium,
      SUM(CASE  when MatchingGift=0 and l.programid = 674 THEN TransAmount - ( TransAmount* ISNULL(premium_annual_expected_pct ,1)) when MatchingGift=1  and l.programid = 674 then MatchAmount - ( MatchAmount*ISNULL(premium_annual_expected_pct,1) ) else 0 END) AS TotalPledges_nonpremium,
        SUM(0) AS TotalReceipts_premium,
      SUM(0) AS TotalReceipts_nonpremium       
		FROM 	advcontact c
     join      advContactTransHeader h  on c.contactid = h.contactid
			JOIN advContactTransLineItems l ON h.TransID = l.TransID
			JOIN advProgram p ON l.ProgramID = p.ProgramID
      left join (select adnumber, 
round(case when  annual_expected  = 0 then 0 else  premium_annual_expected / annual_expected end,2)  premium_annual_expected_pct,
round(case when  annual_expected  = 0 then 0 else   nonpremium_annual_expected / annual_expected  end,2)   non_premium_annual_expected_pct  from (
select accountnumber adnumber, 
sum( py.Annual) annual_expected, 
sum(case when sa.premium_ind = 1 then  py.Annual else 0 end) premium_annual_expected, 
sum(case when isnull(sa.premium_ind,0) = 0 then  py.Annual else 0 end) nonpremium_annual_expected 
  from  amy.seatdetail_individual_history  ct  
  left join seatarea sa on ct.seatareaid = sa.seatareaid
       left join amy.playbookpricegroupseatarea   py on  ct.seatareaid = py.seatareaid and py.pricecodecode = ct.seatpricecode  and
      py.sporttype =  'FB'  and py.ticketyear =  2017
           where  ct.tixeventlookupid =  'F17-Season'
          and cancel_ind is null   and 
          isnull(seatingtype,'') <> 'Suite'
          group by accountnumber ) tt)  percenttb on c.adnumber = percenttb.adnumber
			/*LEFT JOIN 
			(	SELECT DISTINCT ContactID, ProgramID, LevelName
				FROM 	advContactMembershipLevels cl
					JOIN advMembership m ON cl.MembID = m.MembID
					JOIN advMembershipLevels ml ON cl.PledgeLevel = ml.LevelID 
					JOIN advAllocationLevels al ON ml.MembID = al.MembID
				WHERE 	m.TransYear = @trans_year AND m.MembershipName = 'Football'
			) m ON h.ContactID = m.ContactID AND l.ProgramID = m.ProgramID */
		WHERE 	TransDate BETWEEN @start_date AND @end_date AND TransType = 'Cash Pledge'
		GROUP 	BY h.ContactID, l.ProgramID, p.ProgramName , transdate
		UNION
		SELECT 	h.ContactID, 
			l.ProgramID, 
			null LevelName,
			 p.ProgramName  Allocation,  transdate,
			SUM(0) AS TotalPledes,
			SUM(CASE MatchingGift WHEN 0 THEN TransAmount ELSE MatchAmount END) AS TotalReceipts,
     SUM(0) AS TotalPledges_premium,
      SUM(0) AS TotalPledges_nonpremium,
    SUM(CASE  when MatchingGift =0 and l.programid = 674 THEN TransAmount*ISNULL(premium_annual_expected_pct ,1)  when MatchingGift=1  and l.programid = 674 then MatchAmount*ISNULL(premium_annual_expected_pct ,1) else 0 END) AS TotalReceipts_premium,
      SUM(CASE when MatchingGift =0  and l.programid = 674 THEN TransAmount - TransAmount*ISNULL(premium_annual_expected_pct ,1)  when MatchingGift=1  and l.programid = 674 then MatchAmount - MatchAmount*ISNULL(premium_annual_expected_pct ,1) else 0 END) AS TotalReceipts_nonpremium
		FROM 	advcontact c
       join    advContactTransHeader h  on c.contactid = h.contactid
			JOIN advContactTransLineItems l ON h.TransID = l.TransID
			JOIN advProgram p ON l.ProgramID = p.ProgramID
      left join (select adnumber, 
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
          group by accountnumber ) tt)  percenttb on c.adnumber = percenttb.adnumber
		/*	LEFT JOIN 
			(	SELECT DISTINCT ContactID, ProgramID, LevelName
				FROM 	advContactMembershipLevels cl
					JOIN advMembership m ON cl.MembID = m.MembID
					JOIN advMembershipLevels ml ON cl.PledgeLevel = ml.LevelID 
					JOIN advAllocationLevels al ON ml.MembID = al.MembID
				WHERE 	m.TransYear = @trans_year AND m.MembershipName = 'Football'
			) m ON h.ContactID = m.ContactID AND l.ProgramID = m.ProgramID */
		WHERE 	TransDate BETWEEN @start_date AND @end_date AND TransType IN ('Cash Receipt', 'CR Correction') AND ISNULL(PaymentType, '') <> 'NG Credit'
		GROUP 	BY h.ContactID, l.ProgramID,  p.ProgramName , transdate
	) x  where programid = 674
	GROUP BY Allocation, LevelName, transdate
	ORDER BY transdate, Allocation
  
--RETURN
GO
