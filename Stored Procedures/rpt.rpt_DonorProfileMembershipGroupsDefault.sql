SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [rpt].[rpt_DonorProfileMembershipGroupsDefault] (@ADNumber int)

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
--DECLARE @ADNumber INT
--SET @ADNumber = 66529
SET @CurrentYear = (SELECT CurrentYear FROM dbo.ADVCurrentYear)
SET @ContactID = (SELECT ContactID FROM dbo.ADVContact WHERE ADNumber = @ADNumber)

SELECT * FROM 
(
(SELECT	
	R.LevelName + ' (' +
	CAST((
		SELECT 
			COUNT(distinct transyear) 
		FROM dbo.ADVContactMembershipLevels C2
		JOIN dbo.ADVMembership M2 
			ON C2.MembID = M2.MembID
			AND C2.ContactID = C.ContactID
	) AS varchar(100)) 
	+ ' Years)'
	AS GroupNameDefault
    FROM 	dbo.ADVContactMembershipLevels C
  	JOIN dbo.ADVMembership M 	ON (C.MembID = M.MembID  		AND m.transyear = @CurrentYear)
	JOIN dbo.ADVMembershipLevels R 
		ON C.ReceiptLevel = R.LevelID
WHERE c.contactid = @ContactID
and membershipname = '12th Man Foundation - All' ) 
UNION
(SELECT 
	GroupName + ' ' + ISNULL(CASE  WHEN Yrs = 0 or Yrs is null then ''     
		when g.GroupName = 'Endowed' then '('+ cast(DonorCount  as varchar) + ' Seats)'+ ' ' +notes 
    when g.groupid in (3,11) then ''
    when g.groupid = 6 then  '('+endyear + ')'
    else   
    '('+ cast(Yrs as varchar) + ' Year' +case when Yrs = 1 then '' else 's' end + ')'
	END, '') AS GroupName
FROM dbo.ADVQAGroup G 
JOIN (select groupid, contactid , cast(count(distinct memberyear) as varchar) Yrs   , 
 cast(min(memberyear) as varchar)  startyear, cast(max(memberyear) as varchar)  endyear 
 from  ADVQADonorGroupbyYear advdg
	WHERE advdg.contactid = @ContactID 
		AND advdg.memberyear <= @CurrentYear
    group by groupid, contactid )  DG2 
	on  DG2.groupid = g.groupid 
LEFT JOIN dbo.ADVQADonorGroupbyYear DG 
	ON G.GroupID = dg.groupid 
		AND DG.MemberYear = @CurrentYear
		AND DG.ContactId = @ContactID ) 
) a
GO
