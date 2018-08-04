SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [rpt].[rpt_DonorProfileMembershipGroups] (@ADNumber int)

AS

DECLARE @CurrentYear VARCHAR(20)
DECLARE @ContactID INT
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
	AS GroupName
	,'X' AS CurrentGroup
	,'Checked' AS ShowValueAttr
	,1 AS CurrentGroupBool
	,1 AS sort
	,CAST((
		SELECT 
			COUNT(distinct transyear) 
		FROM dbo.ADVContactMembershipLevels C2
		JOIN dbo.ADVMembership M2 
			ON C2.MembID = M2.MembID
			AND C2.ContactID = C.ContactID
	) AS VARCHAR(100)) value
    FROM 	dbo.ADVContactMembershipLevels C
  	JOIN dbo.ADVMembership M 	ON (C.MembID = M.MembID  		AND m.transyear = @CurrentYear)
	LEFT JOIN dbo.ADVMembershipLevels R 
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
	END, '') AS GroupName, 
	CASE WHEN donorcount >= 1 then 'X' else null end CurrentGroup,
	CASE WHEN donorcount >= 1 then 'Checked' else null end ShowValueAttr,
	CASE WHEN donorcount >= 1 then 1 else 0 end CurrentGroupBool,
	CASE 
		WHEN LTRIM(RTRIM(GroupName)) = 'Athletic Ambassadors' THEN 2
		WHEN LTRIM(RTRIM(GroupName)) = 'MVP' THEN 3
		WHEN LTRIM(RTRIM(GroupName)) = 'Champions Council' THEN 4
		WHEN LTRIM(RTRIM(GroupName)) = 'Diamond Champions Council' THEN 5
		WHEN LTRIM(RTRIM(GroupName)) = 'Eppright' THEN 6
		WHEN LTRIM(RTRIM(GroupName)) = 'Board of Trustees' THEN 7
		WHEN LTRIM(RTRIM(GroupName)) = 'Board of Trustees Chair' THEN 8
		WHEN LTRIM(RTRIM(GroupName)) = 'Lettermen ' THEN 9
		WHEN LTRIM(RTRIM(GroupName)) = 'Endowed' THEN 10
		WHEN LTRIM(RTRIM(GroupName)) = 'Faculty/Staff' THEN 11
		WHEN LTRIM(RTRIM(GroupName)) = 'John David Crow Society' THEN 12
		ELSE 99
	END AS sort,
	 CASE  WHEN Yrs = 0 or Yrs is null then ''     
		when g.GroupName = 'Endowed' then '('+ cast(DonorCount  as varchar) + ' Seats)'+ ' ' +notes 
    when g.groupid in (3,11) then ''
    when g.groupid = 6 then  '('+endyear + ')'
    else   
    '('+ cast(Yrs as varchar) + ' Year' + case when Yrs = 1 then '' else 's' end + ')'
	END value
FROM dbo.ADVQAGroup G 
LEFT JOIN (select groupid, contactid , cast(count(distinct memberyear) as varchar) Yrs   , 
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
ORDER BY sort
GO
