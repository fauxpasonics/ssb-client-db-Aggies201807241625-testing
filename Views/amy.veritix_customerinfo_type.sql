SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[veritix_customerinfo_type] as
Select  accountnumber,  c.email, c.firstname, c.lastname, t.stringvalue  from ods.VTXcustomers c,  ods.VTXcustomerfielddata t where t.customerfieldid = 111 and c.id = t.customerid
GO
