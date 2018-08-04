CREATE TABLE [apietl].[MailChimp_Lists_lists_stats_2]
(
[ETL__MailChimp_Lists_lists_stats_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_Lists_lists_id] [uniqueidentifier] NULL,
[member_count] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unsubscribe_count] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleaned_count] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[member_count_since_send] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unsubscribe_count_since_send] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleaned_count_since_send] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[campaign_count] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[campaign_last_sent] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[merge_field_count] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg_sub_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[avg_unsub_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[target_sub_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[open_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[click_rate] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_sub_date] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_unsub_date] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_Lists_lists_stats_2] ADD CONSTRAINT [PK__MailChim__978B2CDF534F2F4A] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_Lists_lists_stats_id])
GO
