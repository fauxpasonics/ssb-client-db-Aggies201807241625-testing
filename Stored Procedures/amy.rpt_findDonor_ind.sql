SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [amy].[rpt_findDonor_ind]
@adnumbername nvarchar(200)
as
select adnumber, 
firstname,lastname,address1,city
from advcontact c, advcontactaddresses ca
where  c.contactid = ca.contactid and
 (cast (adnumber as varchar)  like @adnumbername+'%' or 
 firstname + ' ' + lastname  like '%'+ @adnumbername + '%' ) order by lastname, firstname
GO
