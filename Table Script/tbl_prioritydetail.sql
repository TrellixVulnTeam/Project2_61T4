USE [CentralMI]
GO

/****** Object:  Table [dbo].[prioritydetail]    Script Date: 7/6/2018 12:07:47 PM ******/
DROP TABLE [dbo].[prioritydetail]
GO

/****** Object:  Table [dbo].[prioritydetail]    Script Date: 7/6/2018 12:07:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[prioritydetail](
	[requestpriorityid] [int] IDENTITY(1,1) NOT NULL,
	[requestpriority] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[requestpriorityid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[requestpriority] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


