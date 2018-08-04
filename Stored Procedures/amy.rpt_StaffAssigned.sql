SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_StaffAssigned]
as
select distinct LoginName staffassigned from dbo.AccountGeneralRep ar,  dbo.PacUser pu where pu.clientid = 'TAM'  and ar.GeneralRepUserID = pu.PacUserID
GO
