SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_findDonor] 
@adnumbername nvarchar(200)
as
select top 200 adnumber, 
cast(adnumber as char(10)) + '| '  +cast(isnull(firstname,'') +' ' + isnull(lastname,'') as char(50))  +'| ' +  cast(isnull(address1,'') as char(50)) +'| ' +   cast( isnull(city,'') as char(20)) listname
from advcontact c, advcontactaddresses ca
where  c.contactid = ca.contactid and
 (cast (adnumber as varchar)  like @adnumbername+'%' or 
 firstname + ' ' + lastname  like '%'+ @adnumbername + '%' ) order by lastname, firstname
GO
