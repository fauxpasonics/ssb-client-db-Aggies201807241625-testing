CREATE TABLE [amy].[PriorityEvents]
(
[priorityeventsid] [int] NOT NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prioritypoints] [bit] NULL,
[donorprofile] [bit] NULL,
[advantageload] [bit] NULL,
[createuser] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[createdate] [datetime] NOT NULL,
[updateuser] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedate] [datetime] NOT NULL,
[sporttype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticketyear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sportid] [int] NULL,
[LoadDateExpired] [date] NULL,
[sportregionreport] [bit] NULL,
[sporttotalreport] [bit] NULL,
[loadstartdate] [date] NULL,
[renewalcategory] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewalproductid] [int] NULL,
[relocateproductid] [int] NULL,
[cancelproductid] [int] NULL,
[donationtixeventlookupid] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pktixeventlookupid] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewalorderstart] [datetime] NULL,
[renewalorderend] [datetime] NULL,
[renewal_start_date] [date] NULL,
[renewalordercnt] [int] NULL,
[renewalacctcnt] [int] NULL,
[renewalticketcnt] [int] NULL,
[renewalannualexpected] [int] NULL,
[renewalticketexpected] [int] NULL,
[renewalcapexpected] [int] NULL,
[renewal_id] [int] NULL,
[new_product_ids] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacseason] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacitem] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacparkingitem] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacevent] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacparkingevent] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [amy].[PriorityEvents] ADD CONSTRAINT [PK__Priority__6D6B7DA84D7AD94F] PRIMARY KEY CLUSTERED  ([priorityeventsid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_priorityevents_sporttype_ticketyear] ON [amy].[PriorityEvents] ([sporttype], [ticketyear])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_priorityevents_tixeventlookupid] ON [amy].[PriorityEvents] ([tixeventlookupid])
GO
ALTER TABLE [amy].[PriorityEvents] WITH NOCHECK ADD CONSTRAINT [FK__PriorityE__sport__7F21C18E] FOREIGN KEY ([sportid]) REFERENCES [amy].[Sport] ([SportID])
GO
ALTER TABLE [amy].[PriorityEvents] NOCHECK CONSTRAINT [FK__PriorityE__sport__7F21C18E]
GO
