SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileDonorSumDetail]
AS        
select 1 listid, 'Summary' listDescription
union 
select 2 listid, 'Detail' listDescription
GO
