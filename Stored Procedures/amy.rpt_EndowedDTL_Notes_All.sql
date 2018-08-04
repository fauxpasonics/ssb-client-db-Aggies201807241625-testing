SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_EndowedDTL_Notes_All]  --(@endowedsetupid int)
as
select endowedsetupid, NotesDescr, NotesType, CreateDate from EndowedNotes
GO
