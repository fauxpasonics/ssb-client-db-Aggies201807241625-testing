SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileMembershipGroupsList]
@ADNumber int
AS 
select ReceiptLevel + case when  "Number of years" is not null then ' (' +  cast("Number of years" as varchar) + ' years)' end GroupName, 
case when ReceiptLevel is not null then 'X' else null end CurrentGroup, 
case when ReceiptLevel is not null then  'fa fa-check-circle' else 'fa fa-circle-o'  end ShowValueAttr , 1 sortlevel   from (
select  top 1 ReceiptLevel, "Number of years" from (
  SELECT	
				R.LevelName AS ReceiptLevel,
    (select count(distinct transyear) from 	advContactMembershipLevels C2
		JOIN advMembership M2 ON C2.MembID = M2.MembID  and C2.ContactID = C.ContactID)  "Number of years", 1 slevel
     FROM  advcontact cc join 	advContactMembershipLevels C on cc.ContactID = C.ContactID
		 JOIN advMembership M ON C.MembID = M.MembID and m.transyear =  year(getdate())  
	   left     JOIN advMembershipLevels R ON C.ReceiptLevel = R.LevelID
   where cc.adnumber= @ADNumber  and membershipname = '12th Man Foundation - All' 
   union
   SELECT	
				'Silver Reveille (Lifetime)' AS ReceiptLevel,
    (select count(distinct transyear) from 	advContactMembershipLevels C2
		JOIN advMembership M2 ON C2.MembID = M2.MembID  and C2.ContactID = Cc.ContactID)  "Number of years", 0 slevel
     FROM  advcontact cc where cc.adnumber= @ADNumber  and status = 'Lifetime' ) zz
    ) yy
union all
      select GroupName + case when  CurrentGroup is null and value is not null  and value <> '0' then ' - Past' else '' end +
      case when value is not null and value <> '0' then ' ' + "valuedesc"  else '' end GroupName, 
   CurrentGroup, 
   case when  CurrentGroup is not null then 'fa fa-check-circle' else 'fa fa-circle-o' end ShowValueAttr  , 2 sortlevel  from (
   select GroupName, 
case when donorcount >= 1 or dg.memberyear is not null then 'X' else null end CurrentGroup,
 (select count(distinct memberyear)  from advQADonorGroupbyYear DG2 where
DG2.groupid = g.groupid and  dg2.contactid = (select contactid from advcontact where adnumber =@ADNumber) and dg2.memberyear <=  year(getdate())) "value" , 
case --when donorcount = 0 or donorcount is null then 
when GroupName = 'Endowed' then '('+ cast(DonorCount  as varchar) + ' Seats )'+ ' ' +notes 
else  '('+ (select cast(count(distinct memberyear) as varchar) + ' Years)' from advQADonorGroupbyYear DG2 where
DG2.groupid = g.groupid and dg2.contactid = (select contactid from advcontact where adnumber =@ADNumber) and dg2.memberyear <=  year(getdate()) )
end "valuedesc" 
from advQAGroup G
left join advQADonorGroupbyYear DG 
on  (G.GroupID = dg.groupid and DG.MemberYear = year(getdate()) and DG.ContactId = 
(select contactid from advcontact where adnumber =@ADNumber)) ) t  where @ADNumber is not null and  "valuedesc"  like '%Years%' and "valuedesc" not like '(0 Years)'
 order by sortlevel, groupname
GO
