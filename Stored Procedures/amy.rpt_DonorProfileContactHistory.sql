SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileContactHistory]
@ADNumber int
AS        
select corrdate, type, cc.ContactedBy  "Rep",  subject , 
cast( isnull(notes, '') as varchar(MAX)) "Notes"
from advcontact c, advcontactcorrespondence cc
where c.contactid  = cc.contactid  and c.adnumber = @ADNumber order BY  corrdate DESC
GO
