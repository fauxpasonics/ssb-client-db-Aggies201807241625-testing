SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_Renewal_Dashboard_TTL_test] (
   @sporttype     VARCHAR (20),
   @ticketyear    VARCHAR (4))
AS
   DECLARE @tixeventlookupid   VARCHAR (20)
   DECLARE @renewalacctcnt   INT
   DECLARE @renewalannualexpected   INT
   DECLARE @renewalticketcnt   INT

   SELECT @renewalacctcnt = renewalacctcnt,
          @renewalticketcnt = renewalticketcnt,
          @renewalannualexpected = renewalannualexpected
   FROM PriorityEvents
   WHERE sporttype = @sporttype AND ticketyear = @ticketyear

   SET @tixeventlookupid =
          (SELECT tixeventlookupid
             FROM amy.PriorityEvents pe1
            WHERE sporttype = @sporttype AND ticketyear = @ticketyear);

   SELECT *
     FROM (SELECT CASE
                     WHEN Donorrenewed = 0
                     THEN
                        NULL
                     ELSE
                          Cast (Donorrenewed AS VARCHAR)
                        + ' ('
                        + Cast (perdonorrenewed AS VARCHAR)
                        + '%)  Web:'
          + Cast (webrenewals AS VARCHAR)
          + ' ('
          + Cast (perwebrenewed AS VARCHAR)
                  END
                     "Donors Renewed",
                    Cast (ticketrenewed AS VARCHAR)
					          + ' of '
          + CONVERT (VARCHAR, @renewalticketcnt, 1)
                  + ' ('
                  + Cast (perticketrenewed AS VARCHAR)
                  + '%)'
                     "Tickets Renewed",
                    '$'
                  + CONVERT (VARCHAR, receipts, 1)
                  + ' ('
                  + Cast (PerPaymentsReceived AS VARCHAR)
                  + '%)'
                     "Annual Received",
                    '$'
                  + CONVERT (VARCHAR,
                             (receipts + matchreceipts + ScheduledAnnual),
                             1)
                  + ' ('
                  + Cast (PerScheduledReceived AS VARCHAR)
                  + '%)'
                     "Annual Received/Scheduled",
                    '$'
                  + CONVERT (VARCHAR, Pledge, 1)
                  + ' ('
                  + Cast (perpledge AS VARCHAR)
                  + '%)'
                     "Annual Pledges",
                  '$' + CONVERT (VARCHAR, ALLCAPPledge, 1) "CAP Pledges",
                    '$'
                  + CONVERT (VARCHAR, ALLCAPRECEIPTS, 1)
                  + ' ('
                  + Cast (percapreceived AS VARCHAR)
                  + '%)'
                     "CAP Receipts",
                  '$' + CONVERT (VARCHAR, cast (OutstandingCAP AS MONEY), 1)
                     "CAP Expected"
             FROM (SELECT s.*,
                          CASE
                             WHEN annualDue <> 0
                             THEN
                                (receipts / annualDue) * 100
                             ELSE
                                0
                          END
                             PerPaymentsReceived,
                          CASE
                             WHEN annualDue <> 0
                             THEN
                                  (receipts + matchreceipts + ScheduledAnnual)
                                / annualDue
                                * 100
                             ELSE
                                0
                          END
                             PerScheduledReceived,
							                   round (
                       cast (webrenewals AS FLOAT)
                     / cast (@renewalacctcnt AS FLOAT) --cast(donorseatcounttotal as float)
                     * 100,
                     2)
                     perwebrenewed,
                          CASE
                             WHEN cast (@renewalacctcnt AS FLOAT) <> 0
                             THEN
                                round (
                                     cast (donorrenewed AS FLOAT)
                                   / cast (@renewalacctcnt AS FLOAT)
                                   * 100,
                                   2)
                             ELSE
                                0
                          END
                             perdonorrenewed,   --replace  donorseatcounttotal
                          CASE
                             WHEN cast (@renewalticketcnt AS FLOAT) <> 0
                             THEN
                                round (
                                     cast (ticketrenewed AS FLOAT)
                                   / cast (@renewalticketcnt AS FLOAT)
                                   * 100,
                                   2)
                             ELSE
                                0
                          END
                             perticketrenewed,     --replace  ticketcounttotal
                          CASE
                             WHEN @renewalannualexpected <> 0
                             THEN
                                round (Pledge / @renewalannualexpected * 100,  2)
                             ELSE
                                0
                          END
                             perpledge,                    --replace AnnualDue
                          CASE
                             WHEN ALLCAPPledge * 100 <> 0
                             THEN
                                round (ALLCAPRECEIPTS / ALLCAPPledge * 100,
                                       2)
                             ELSE
                                0
                          END
                             percapreceived,
                          CASE
                             WHEN cast (ALLCAPPledge AS FLOAT) * 100 <> 0
                             THEN
                                round (
                                     cast (OutstandingCAP AS FLOAT)
                                   / cast (ALLCAPPledge AS FLOAT)
                                   * 100,
                                   1)
                             ELSE
                                0
                          END
                             percapoutstanding
                     FROM (SELECT count (
                                     DISTINCT CASE
                                                 WHEN "Ticket Total"
                                                         IS NOT NULL
                                                 THEN
                                                    adnumber
                                                 ELSE
                                                    NULL
                                              END)
                                     donorseatcounttotal,
                                  COUNT (
                                     DISTINCT CASE
                                                 WHEN     "Ticket Total"
                                                             IS NOT NULL
                                                      AND (  
													   renewal_date   IS NOT NULL  
													 /* (  isnull ( "Adv Annual Receipt",  0)
                                                               + isnull ( "Adv Annual Match Receipt",  0)
                                                               + isnull (    "AnnualScheduledPayments",  0) > 0)
                                                           OR isnull (  t.ticketpaidpercent,  0) > 0
                                                           OR min_annual_receipt_date   IS NOT NULL	  )*/
                                                 OR (    (  isnull (
                                                                 ordergroupbottomlinegrandtotal,
                                                                 0)
                                                            - isnull (
                                                                 ordergrouptotalpaymentscleared,
                                                                 0)
                                                            - isnull (
                                                                 ordergrouptotalpaymentsonhold,
                                                                 0) <= 0)
                                                       AND (  isnull (Annual,
                                                                      0)
                                                            - isnull (
                                                                 "Adv Annual Receipt",
                                                                 0)
                                                            - isnull (
                                                                 "Adv Annual Match Pledge",
                                                                 0)
                                                            - isnull (
                                                                 AnnualScheduledPayments,
                                                                 0)
                                                            - isnull (
                                                                 "Adv Annual Credit",
                                                                 0) <= 0)))
												 THEN
                                                    ADNUMBER
                                                 ELSE
                                                    NULL
                                              END)
                                     donorrenewed,
						 COUNT (
                             DISTINCT CASE
                                         WHEN     "Ticket Total" IS NOT NULL
                                              AND (renewal_date IS NOT NULL)
                                         THEN
                                            ADNUMBER
                                         ELSE
                                            NULL
                                      END)
                             webrenewals,
                                  sum ("Ticket Total"- isnull (newtickets, 0)) ticketcounttotal,
                                  sum (
                                     CASE when
                                       /* WHEN    (  isnull (    "Adv Annual Receipt",   0)       
										+ isnull (  "Adv Annual Match Receipt",    0)                                              + isnull (  "AnnualScheduledPayments",  0) > 0)
                                             OR isnull (t.ticketpaidpercent, 0) > 0
                                             OR min_annual_receipt_date
                                                   IS NOT NULL */
											 (   renewal_date IS NOT NULL
                                      OR (    (  isnull (
                                                    ordergroupbottomlinegrandtotal,
                                                    0)
                                               - isnull (
                                                    ordergrouptotalpaymentscleared,
                                                    0)
                                               - isnull (
                                                    ordergrouptotalpaymentsonhold,
                                                    0) <= 0)
                                          AND (  isnull (Annual, 0)
                                               - isnull (
                                                    "Adv Annual Receipt",
                                                    0)
                                               - isnull (
                                                    "Adv Annual Match Pledge",
                                                    0)
                                               - isnull (
                                                    AnnualScheduledPayments,
                                                    0)
                                               - isnull ("Adv Annual Credit",
                                                         0) <= 0)))	   
                                        THEN
                                           "Ticket Total"- isnull (newtickets, 0)
                                        ELSE
                                           0
                                     END)
                                     ticketrenewed,
                                  sum (
                                       isnull ("Adv Annual  Pledge", 0)
                                     + isnull ("Adv Annual Match Pledge", 0))
                                     Pledge,
                                  sum (annual) AnnualDue,
                                  sum (
                                       isnull ("Adv Annual Receipt", 0)
                                     + isnull ("Adv Annual Match Receipt", 0))
                                     Receipts,
                                  sum (isnull ("Adv Annual Receipt", 0)) RegReceipts,
                                  sum ( isnull ("Adv Annual Match Receipt", 0))
                                     MatchReceipts,
                                  sum (isnull ("AnnualScheduledPayments", 0))
                                     ScheduledAnnual,
                                  sum (
                                       isnull ("Adv CAP Pledge", 0)
                                     + isnull ("Adv CAP Match Pledge", 0))
                                     ALLCAPPledge,
                                  sum (
                                       isnull ("Adv CAP Receipt AMount", 0)
                                     + isnull ("Adv CAP Match Receipt", 0))
                                     ALLCAPRECEIPTS,
                                  sum (
                                     CASE
                                        WHEN CapStillDue > 0 THEN CapStillDue
                                        ELSE 0
                                     END)
                                     OutstandingCAP,
                           max (ordergroupbottomlinegrandtotal)
                             ordergroupbottomlinegrandtotal,
                          max (ordergrouptotalpaymentscleared)
                             ordergrouptotalpaymentscleared,
                          max (ordergrouptotalpaymentsonhold)
                             ordergrouptotalpaymentsonhold,
                          sum ("Adv Annual Credit") "Adv Annual Credit"
                     FROM (SELECT adnumber,
                                  sum ("Ticket Total") "Ticket Total",
                                  sum (isnull ("Adv Annual Receipt", 0))
                                     "Adv Annual Receipt",
                                  sum (
                                     isnull ("Adv Annual Match Receipt", 0))
                                     "Adv Annual Match Receipt",
                                  sum (isnull ("AnnualScheduledPayments", 0))
                                     "AnnualScheduledPayments",
                                  min (isnull (t.ticketpaidpercent, 0))
                                     ticketpaidpercent,
                                  min (min_annual_receipt_date)
                                     min_annual_receipt_date,
                                  sum (isnull ("Adv Annual  Pledge", 0))
                                     "Adv Annual  Pledge",
                                  sum (isnull ("Adv Annual Match Pledge", 0))
                                     "Adv Annual Match Pledge",
                                  sum (annual) annual,
                                  sum (isnull ("Adv CAP Pledge", 0))
                                     "Adv CAP Pledge",
                                  sum (isnull ("Adv CAP Match Pledge", 0))
                                     "Adv CAP Match Pledge",
                                  sum (isnull ("Adv CAP Receipt AMount", 0))
                                     "Adv CAP Receipt AMount",
                                  sum (isnull ("Adv CAP Match Receipt", 0))
                                     "Adv CAP Match Receipt",
                                  sum (capstilldue) capstilldue,
                                  --sum(case when  seatregionname not like '%Suite%' then (isnull(t.capstilldue,0)) else 0 end)OutstandingNONSUITECAP,
                                  --sum(case when  seatregionname like '%Suite%' then isnull(t.capstilldue,0) else 0 end) OutstandingSUITECAP,
                                  sum (isnull (t.Annual, 0)) ExpectedPledge,
                                  sum (isnull (newticket, 0)) newtickets,
                                  min (renewal_date) renewal_date,
                                  t.ordergroupbottomlinegrandtotal,
                                  t.ordergrouptotalpaymentscleared,
                                  t.ordergrouptotalpaymentsonhold,
                                  sum (isnull ("Adv Annual Credit", 0))
                                     "Adv Annual Credit"
                             FROM RPT_SEATrecon_TB t
                            WHERE     ticketyear =    @ticketyear 
                                  AND sporttype = @sporttype
                           GROUP BY adnumber,
                                    t.ordergroupbottomlinegrandtotal,
                                    t.ordergrouptotalpaymentscleared,
                                    t.ordergrouptotalpaymentsonhold) t 
                          ) s) TT) t1
GO
