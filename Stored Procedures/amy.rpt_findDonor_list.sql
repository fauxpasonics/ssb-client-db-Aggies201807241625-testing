SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [amy].[rpt_findDonor_list] as
 select adnumber, right (cast(adnumber as varchar(15)),30) + '| ' + right (isnull(firstname,'') + ' ' + isnull(lastname,'') ,500) + '|'   tt from advcontact c, advcontactaddresses ca
where  c.contactid = ca.contactid and adnumber is not null
GO
