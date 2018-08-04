SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_EndowedDTL] (@endowedsetupid int) as
select adnumber, AccountName , pastadnumber, EndowmentNumber, activestatus, Endowment , establishedyear, EndDateInitialLength, Terms,
Beneficiaries, SpouseName, Notes, PriceCode, SeasonQty, RoadGameQty, ActualQtyUsed, EndowedCreditTotal, endowedsetupid  from EndowedSetup where endowedsetupid = @endowedsetupid
GO
