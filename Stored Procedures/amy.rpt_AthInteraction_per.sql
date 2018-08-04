SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_AthInteraction_per]
as
begin
select ctype, amt, cast( amt as decimal)/ cast(ttl  as decimal) *100  peramt , ttl from (
select 'Converted Donor' ctype, ConvertedDonor amt, ttl	from rpt_AthInteraction_vw
union
select 'Pre Donor' ctype, preDonor amt, ttl		from rpt_AthInteraction_vw
union
select 'FlashSeats' ctype,NotDonorsFS amt, ttl		from rpt_AthInteraction_vw
union
select 'Promos' ctype, JerseyPromo + ArkansasPromo+ HelmetPromo	 amt, ttl		from rpt_AthInteraction_vw
union
select 'Athletics Shop' ctype, AthShop amt, ttl		from rpt_AthInteraction_vw
union
select 'Online Auctions' ctype,OnlineAuction amt, ttl		from rpt_AthInteraction_vw
) f
end
GO
