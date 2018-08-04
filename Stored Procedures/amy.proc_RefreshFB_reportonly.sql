SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[proc_RefreshFB_reportonly]
AS

begin

        exec [amy].[proc_SeatReconReport_table] 'F18-Season'
        exec [amy].[proc_SeatTicketOrder_table]  'F18-Season'

         exec [amy].[proc_SeatRegionReport_table] 'FB','2018',3
         exec proc_FB_order_list null
               exec  [amy].[proc_update_allfootball] 2018
 end
GO
