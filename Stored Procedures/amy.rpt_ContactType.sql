SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_ContactType]  as
select 'Donor' ContactType
Union select  'Inactive Donor'
Union select 'Tickets Only'
Union select 'Flash Seats'
Union select 'Athletics Source'
GO
