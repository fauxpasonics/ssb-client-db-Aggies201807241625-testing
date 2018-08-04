SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[donorcategory_vw]
as
select adnumber  , cast(adnumber as varchar) acct, cast(adnumber as varchar) patron, dc.CategoryCode, dc.CategoryName, cdc.[Value]
from advcontact c,  
advdonorcategories dc, 
advcontactdonorcategories cdc
where c.contactid = cdc.contactid and dc.PK = cdc.CategoryID
GO
