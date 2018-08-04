CREATE TABLE [dbo].[ContactCorrespondence]
(
[PK] [int] NOT NULL,
[ContactID] [int] NULL,
[ContactedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CorrDate] [datetime] NULL,
[Contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Private] [bit] NULL,
[SentToTixOffice] [bit] NULL,
[DateTimeSentToTixOffice] [datetime] NULL,
[ProposedDonation] [money] NULL,
[NegotiatedDonation] [money] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ContactCorrespondence] ADD CONSTRAINT [PK_ContactCorrespondence_4259dc54-a0d2-451f-8fa8-e48a0d7085a4] PRIMARY KEY CLUSTERED  ([PK])
GO
CREATE NONCLUSTERED INDEX [IX_ContactIDCorrDate] ON [dbo].[ContactCorrespondence] ([ContactID], [CorrDate])
GO
