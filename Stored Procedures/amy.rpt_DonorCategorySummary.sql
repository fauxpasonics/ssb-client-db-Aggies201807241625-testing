SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorCategorySummary] ( @DONORCAT nvarchar(1000)= null )
as
begin


declare @querysql nvarchar(MAX)

set @querysql =
'select j.*, ca.Address1, ca.Address2, ca.Address3, ca.Zip, ca.State, ca.City, ca.Salutation from (
select  c.adnumber, accountname, firstname, lastname, status, udf2 donortype, Lifetimegiving, AdjustedPP, pprank, email , c.PHHome, c.PHBusiness,
categoryname, c.contactid
from advcontact c, advcontactdonorcategories cdc
, advDonorCategories dc
where c.contactid = cdc.contactid and dc.pk = cdc.categoryid and '
 +''','+ @DONORCAT +','' '+' like ' + '   ''%,'' +cast(cdc.categoryid as varchar)+'',%'' ' +    
') j left join amy.advcontactaddresses_unique_primary_vw ca on j.contactid = ca.contactid order by adnumber, categoryname'


execute( @querysql)

-- select @querysql
end
GO
