SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_athinteractions] 
( @STATUS bit = 0,  @SOURCEPROMO nvarchar(MAX)= null, @CONTACTTYPE nvarchar(MAX)= null, 
@transtype nvarchar(50) = 'START') as
select p.* from (select c.fullname,  c.FirstName, c.LastName, c.email,  t.contactgrouptype, t.EventType, t.Descr, i.contact_date , optin , c.id contactid, i.contacttype,
 case when isnull(tmfind,0)=1   and DonorStatus in ('Active','Lifetime') then 'Donor'
   when isnull(tmfind,0)=1    and DonorStatus  not in ('Active','Lifetime') then 'Inactive Donor'
   when isnull(tmfind,0)=0   and ticketingind =1   then 'Tickets Only'
   when isnull(tmfind,0)=0   and  isnull(ticketingind,0)=0 and isnull(fsind,0) = 1   then 'Flash Seats'
   else 'Athletics Source'  
 end ContactTypesource  
from athcontacts c, athInteraction i,
athcontacttypes t where c.id = i.id and  t.id = i.contacttypeid ) p where 
((@STATUS = 1 and isnull(optin,0)  = 1) or @Status = 0) And
((@SOURCEPROMO  is not null  and    ','+@SOURCEPROMO  +',' like  '%,'+contacttype+',%') or @SOURCEPROMO is null) 
and 
((@CONTACTTYPE is not null and   ','+@CONTACTTYPE  +',' like  '%,'+ContactTypesource  +',%'   ) or @CONTACTTYPE is null)
order by  p.contactid, p.contact_date
GO
