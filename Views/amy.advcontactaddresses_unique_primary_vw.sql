SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [amy].[advcontactaddresses_unique_primary_vw] as select caa.* from advcontactaddresses caa , 
               (select contactid, min(pk) minpk 
                      from advcontactaddresses ca1 
                      where primaryaddress = 1
               group by contactid) ca2 where caa.contactid = ca2.contactid and caa.pk  = ca2.minpk
GO
