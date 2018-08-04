SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[email_feed_vw] as
select cast(adnumber as varchar) accountnumber, firstname, lastname, email,  status, 
 accountname, 
--(select stringvalue from ods.VTXcustomerfielddata x,  ods.VTXcustomers c where customerfieldid = 111 and x.customerid = c.id and c.accountnumber = cast(adnumber as varchar)  ) customertype, 
STUFF(( SELECT	',' + GroupName
				FROM	advqagroup g, ADVQADonorGroupbyYear gy where g.groupid = gy.groupid and  MemberYear = year (getdate()) and contactid = a.contactid
        and gy.groupid in (1,2)
				ORDER BY groupname
				FOR XML	PATH('')
				), 1, 1, '') DonorGroups
from advcontact a where email is not null
union 
select accountnumber, firstname, lastname, email, 'VTXOnly' status, 
(select stringvalue from ods.VTXcustomerfielddata where customerfieldid in (1007) and customerid = c.id) accountname, 
--(select stringvalue from ods.VTXcustomerfielddata where customerfieldid in (111) and customerid = c.id  ) customertype,
null DonorGroups
from ods.VTXcustomers c where accountnumber in (
SELECT ACCOUNTNUMBER FROM amy.SEATdetail_individual_history
except
select cast(adnumber as varchar) from advcontact)
and email is not null
GO
