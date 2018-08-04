SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorGroupReport] ( @groupid int = -1, @memberyear varchar(4) = null , @startmemberyear varchar(4) = null, @endmemberyear  varchar(4)= null)

as

if @memberyear is null  and @startmemberyear is null
begin
set @memberyear = cast(year(getdate()) as varchar);
end

select   g.groupname,DGY.MemberYear, adnumber, c.accountname, c.firstname, c.lastname, c.status, c.udf2 donortype,
c.LifetimeGiving, c.AdjustedPP, case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank, 
c.UDF4 MajorGiftName, c.Email,c.PHHome, c.PHBusiness,c.PHOther1Desc, c.PHOther1,   
DGY.ComplimentaryMembership,  DGY.ComplimentaryMembershipReason,
DGY.DonorCount, DGY.TerritoryCode,  DGY.Notes, DGY.UpdateDate, DGY.CreateDate, DGY.EstimatedYear ,
c.udf5 MailingName, ca.Address1, ca.Address2, ca.Address3, ca.City, ca.State, ca.Zip, ca.Salutation,
(select sum(transamount+ matchamount) ttlamount
from advcontacttransheader h,
advcontacttranslineitems li
where h.transid = li.transid and 
li.programid = g.programid and DGY.MemberYear   = transyear
and transtype like '%Receipt%' and g.programid is not null
and h.contactid = c.contactid
) ReceiptAmount
FROM advcontact c
join ADVQADonorGroupbyYear DGY on  c.contactid = dgy.contactid 
join ADVQAGroup G on g.groupid = dgy.groupid
left join amy.advcontactaddresses_unique_primary_vw ca on c.contactid= ca.contactid and primaryaddress = 1
where (g.groupid = @groupid or @groupid = -1) and
(( @memberyear is not null and DGY.MemberYear = @memberyear) or 
( @memberyear is  null and DGY.MemberYear between  @startmemberyear and  @endmemberyear ) )
order by lastname, adnumber, groupname,memberyear
/*
select   g.groupname,DGY.MemberYear, adnumber, c.accountname, c.firstname, c.lastname, c.status, c.udf2 donortype,
c.LifetimeGiving, c.AdjustedPP, case when pprank = 0 then 99999 else  isnull(c.PPRank, 99999) end  pprank, 
c.UDF4 MajorGiftName, c.Email,c.PHHome, c.PHBusiness,c.PHOther1Desc, c.PHOther1,   
DGY.ComplimentaryMembership,  DGY.ComplimentaryMembershipReason,
DGY.DonorCount, DGY.TerritoryCode,  DGY.Notes, DGY.UpdateDate, DGY.CreateDate, DGY.EstimatedYear ,
c.udf5 MailingName, ca.Address1, ca.Address2, ca.Address3, ca.City, ca.State, ca.Zip, ca.Salutation
(select sum(transamount+ matchamount) ttlamount, 
from ad12thman..contacttransheader h,
ad12thman..contacttranslineitems li
where h.transid = li.transid and 
li.programid = g.programid and DGY.MemberYear   = transyear
and transtype like '%Receipt%' g.programid is not null
) ReceiptAmount
FROM advcontact c
join ADVQADonorGroupbyYear DGY on  c.contactid = dgy.contactid 
join ADVQAGroup G on g.groupid = dgy.groupid
left join advcontactaddresses ca on c.contactid= ca.contactid and primaryaddress = 1
where (g.groupid = @groupid or @groupid = -1) and
(( @memberyear is not null and DGY.MemberYear = @memberyear) or 
( @memberyear is  null and DGY.MemberYear between  @startmemberyear and  @endmemberyear ) )
order by lastname, adnumber, groupname,memberyear */
GO
