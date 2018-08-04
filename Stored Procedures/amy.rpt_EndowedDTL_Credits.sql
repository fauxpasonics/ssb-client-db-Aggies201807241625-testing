SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_EndowedDTL_Credits] (@endowedsetupid int)
as
select endowedsetupid, SeatRegionName, RenewalYear, Credit, TicketQty, E, EC, ZCE, DriveYear, CreditType, Notes, Creditapplieddate from EndowedCreditsbyYear  where endowedsetupid= @endowedsetupid
GO
