SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_SourcePromo] as
select distinct contacttype from athInteraction
GO
