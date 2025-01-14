USE [master]
GO
/****** Object:  Database [CentralMI]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE DATABASE [CentralMI]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CentralMI', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\CentralMI.mdf' , SIZE = 68608KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'CentralMI_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\CentralMI_log.ldf' , SIZE = 2304KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [CentralMI] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [CentralMI].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [CentralMI] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CentralMI] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CentralMI] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CentralMI] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CentralMI] SET ARITHABORT OFF 
GO
ALTER DATABASE [CentralMI] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CentralMI] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [CentralMI] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CentralMI] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CentralMI] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CentralMI] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CentralMI] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CentralMI] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CentralMI] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CentralMI] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CentralMI] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CentralMI] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CentralMI] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CentralMI] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [CentralMI] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [CentralMI] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CentralMI] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CentralMI] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [CentralMI] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CentralMI] SET  MULTI_USER 
GO
ALTER DATABASE [CentralMI] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CentralMI] SET DB_CHAINING OFF 
GO
ALTER DATABASE [CentralMI] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [CentralMI] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [CentralMI]
GO
/****** Object:  User [test]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE USER [test] FOR LOGIN [test] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [djangoapp]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE USER [djangoapp] FOR LOGIN [djangoapp] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  StoredProcedure [dbo].[usp_activity_calendar]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE PROCEDURE [dbo].[usp_activity_calendar]
@inputdate varchar(50),
@inputfreq varchar(50)
AS
SELECT A.[date]
      ,A.[daytype]
      ,A.[weekname]
      ,A.[CD_WD_days]
      ,A.[activityid]
      ,A.[frequency]
	  ,B.deliverytime
	  ,B.description
	  ,B.name
	  ,B.requestcategorys
	  ,B.primaryowner
	  ,B.secondaryowner
	  ,c.activitystatusdate
	  ,c.activitystatus
	  ,c.activitycalendardate
	  ,c.reallocatedto
	  ,C.recordenteredby
	  ,D.teamname
	  ,G.activitystatus
	  ,H.statusname
  FROM [CentralMI].[dbo].[activity_calendar] A
  Left Join [CentralMI].[dbo].[activity] B on A.[activityid] = B.[activityid]
  Left Join [CentralMI].[dbo].[activitystatus_calendar] C on B.[activityid] = C.[activityid]
  Left Join [CentralMI].[dbo].[teamdetail] D on B.teamname = D.teamid
  Left Join  [CentralMI].[dbo].[activitystatus] G on B.activitystatus = G.activitystatusid
  Left Join  [CentralMI].[dbo].[statusdetail] H on C.activitystatus = H.statusnameid

 where A.date in (@inputdate)
  and A.frequency in (@inputfreq)
  and G.activitystatus not in ('Closed')
  and  (H.statusname not in ('Completed','Rejected') or H.statusname  is null) 

  
GO
/****** Object:  StoredProcedure [dbo].[uspjoin]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspjoin]  
@status varchar(50),
@stage varchar(50)
As
SELECT A.[requestid]
      ,A.[requestraiseddate]
	  ,J.[requestpriority]
	  ,K.[requesttype]
      ,A.[requestdescription] 
	  ,B.[authoriseddate]
	  ,L.[username] As authorisedby
	  ,C.[assignedDate]
	  ,M.[username] as assignedby
	  ,N.[username] as assignedto
	  ,D.[overviewdate]
	  ,O.[username] as providedby
	  ,P.[username] as givenby
	  ,Q.[optionsname]
	  ,D.[document]
	  ,E.[estimationdate]
	  ,R.[username] as estimatedby
	  ,E.[estimateddays]
	  ,F.[estacceptrejectdate]
	  ,S.[username] as acceptedrejectedby
	  ,G.[completeddate]
	  ,T.[username] as completedby
	  ,H.[requeststatusdate]
	  ,I.[statusname]
	   ,Case
			When  G.completeddate is not null Then 'CompletedStage'
				When  F.estacceptrejectdate is not null then  'WIPStage'
				When  E.[estimationdate]  is not null Then 'EstimateStage' 
				When  D.[overviewdate] is not null Then 'OverviewStage'
				When  c.[assignedDate] is not null then 'AssignedStage'
				When  B.[authoriseddate] is not null Then  'AuthorisedStage'
				When  A.[requestraiseddate] is not null then 'RequestStage'
			   End As Current_Stage   
	   FROM [requestdetail]  as A
	   left Join [prioritydetail]    as J on  A.[prioritydetail] = J.[requestpriorityid] 
	   left Join [requesttypedetail]    as K on  A.[requesttypedetail] = K.[requesttypeid] 
	   left Join [authorisedetail]    as B on  A.[requestid] = B.[requestdetail] 
	   left Join [assigneddetail]     as C on  A.[requestid] = C.[requestdetail] 
	   left Join [overviewdetail]     as D on  A.[requestid] = D.[requestdetail] 
	   left Join [estimationdetail]   as E on  A.[requestid] = E.[requestdetail] 
	   left Join [acceptrejectdetail] as F on  A.[requestid] = F.[requestdetail] 
	   left Join [completeddetail]    as G on  A.[requestid] = G.[requestdetail]
	   left Join [requeststatusdetail]as H on  A.[requestid] = H.[requestdetail]
	   left Join [statusdetail] as I  on  H.statusdetail = I.[statusnameid]
	   left Join [auth_user] as L on B.[authoriserdetail] = L.[ID]
	   left Join [auth_user] as M on C.[assignedby] = M.[ID] 
	   left Join [auth_user] as N on C.[assignedto]= N.[ID]
	   left Join [auth_user] as O on D.[providedby] =  O.[ID]
	   left Join [auth_user] as P on D.[mimember] =  P.[ID]
	   left Join [auth_user] as R on E.[estimatedby] =  R.[ID]
	   left Join [auth_user] as S on F.[estacceptrejectby] =  S.[ID]
	   left Join [auth_user] as T on G.[completedby] =  T.[ID]

	   left Join [options] as Q on D.[sopcreatedoptionsid] = Q.[optionsid]
	   where
	   (case when @status = 'All' then 'All' else I.[statusname] end )  = @status
		and 
	   (Case 
			when @stage = 'All' then 'All' Else 
		    ( Case
				When  G.completeddate is not null Then 'CompletedStage'
				When  F.estacceptrejectdate is not null then  'WIPStage'
				When  E.[estimationdate]  is not null Then 'EstimateStage' 
				When  D.[overviewdate] is not null Then 'OverviewStage'
				When  c.[assignedDate] is not null then 'AssignedStage'
				When  B.[authoriseddate] is not null Then  'AuthorisedStage'
				When  A.[requestraiseddate] is not null then 'RequestStage'
			End	  
			) 
	
		End) = @stage
	   

 
GO
/****** Object:  Table [dbo].[acceptrejectdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[acceptrejectdetail](
	[estacceptrejectid] [int] IDENTITY(1,1) NOT NULL,
	[estacceptrejectdate] [datetime] NOT NULL,
	[estacceptrejectby] [int] NOT NULL,
	[requestdetail] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[estacceptrejectid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[acceptrejectoption]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[acceptrejectoption](
	[acceptrejectoptionid] [int] IDENTITY(1,1) NOT NULL,
	[acceptrejectoptionname] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[acceptrejectoptionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[acceptrejectoptionname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[activity]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[activity](
	[activityid] [int] IDENTITY(1,1) NOT NULL,
	[registereddate] [datetime] NOT NULL,
	[name] [varchar](255) NULL,
	[frequency] [int] NULL,
	[date_types] [int] NULL,
	[delivery_days] [int] NULL,
	[deliverytime] [time](7) NULL,
	[teamname] [int] NULL,
	[primaryowner] [int] NULL,
	[secondaryowner] [int] NULL,
	[description] [varchar](255) NULL,
	[requestcategorys] [int] NULL,
	[activitystatus] [int] NULL,
	[activitydocument] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[activityid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[activity_calendar]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[activity_calendar](
	[date] [date] NULL,
	[daytype] [varchar](50) NULL,
	[weekname] [varchar](50) NULL,
	[CD_WD_days] [int] NULL,
	[activityid] [int] NULL,
	[frequency] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[activitystatus]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[activitystatus](
	[activitystatusid] [int] IDENTITY(1,1) NOT NULL,
	[activitystatus] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[activitystatusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[activitystatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[activitystatus_calendar]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[activitystatus_calendar](
	[activitystatuscalendarid] [int] IDENTITY(1,1) NOT NULL,
	[activitystatusdate] [datetime] NOT NULL,
	[activitystatus] [int] NULL,
	[activityid] [int] NULL,
	[activitycalendardate] [date] NULL,
	[reallocatedto] [int] NULL,
	[recordenteredby] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[activitystatuscalendarid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[assign_view]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[assign_view](
	[viewassign_id] [int] IDENTITY(1,1) NOT NULL,
	[group_name] [int] NOT NULL,
	[view_type] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[viewassign_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[assigneddetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[assigneddetail](
	[assignedid] [int] IDENTITY(1,1) NOT NULL,
	[assignedDate] [datetime] NOT NULL,
	[assignedto] [int] NULL,
	[assignedby] [int] NULL,
	[requestdetail] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[assignedid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[auth_group]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](80) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[auth_group_permissions]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_group_permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[group_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_group_permissions_group_id_permission_id_0cd325b0_uniq] UNIQUE NONCLUSTERED 
(
	[group_id] ASC,
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[auth_permission]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_permission](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[content_type_id] [int] NOT NULL,
	[codename] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_permission_content_type_id_codename_01ab375a_uniq] UNIQUE NONCLUSTERED 
(
	[content_type_id] ASC,
	[codename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[auth_user]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[password] [nvarchar](128) NOT NULL,
	[last_login] [datetime2](7) NULL,
	[is_superuser] [bit] NOT NULL,
	[username] [nvarchar](150) NOT NULL,
	[first_name] [nvarchar](30) NOT NULL,
	[last_name] [nvarchar](30) NOT NULL,
	[email] [nvarchar](254) NOT NULL,
	[is_staff] [bit] NOT NULL,
	[is_active] [bit] NOT NULL,
	[date_joined] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_user_username_6821ab7c_uniq] UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[auth_user_groups]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user_groups](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[group_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_user_groups_user_id_group_id_94350c0c_uniq] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[auth_user_user_permissions]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[auth_user_user_permissions](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[permission_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [auth_user_user_permissions_user_id_permission_id_14a6b632_uniq] UNIQUE NONCLUSTERED 
(
	[user_id] ASC,
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[authorisedetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authorisedetail](
	[authorisedid] [int] IDENTITY(1,1) NOT NULL,
	[authoriseddate] [datetime] NOT NULL,
	[authoriserdetail] [int] NULL,
	[requestdetail] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[authorisedid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[authoriserdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authoriserdetail](
	[authoriserid] [int] IDENTITY(1,1) NOT NULL,
	[username] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[authoriserid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Calendar]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendar](
	[date] [date] NULL,
	[calendar_days] [int] NULL,
	[calendar_Weekday] [int] NULL,
	[calendar_months] [int] NULL,
	[calendar_days_rest] [int] NULL,
	[working_days] [int] NULL,
	[working_weekday] [int] NULL,
	[working_months] [int] NULL,
	[working_days_rest] [int] NULL,
	[weeknum] [int] NULL,
	[month] [int] NULL,
	[year] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CalendarHolidays]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CalendarHolidays](
	[CalendarDate] [datetime2](7) NOT NULL,
	[CalendarFunction] [int] NOT NULL,
	[HolidayType] [varchar](100) NULL,
 CONSTRAINT [PK_Holidays_Id] PRIMARY KEY CLUSTERED 
(
	[CalendarDate] ASC,
	[CalendarFunction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[completeddetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[completeddetail](
	[completedid] [int] IDENTITY(1,1) NOT NULL,
	[completeddate] [datetime] NOT NULL,
	[completedby] [int] NULL,
	[requestdetail] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[completedid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[date_types]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[date_types](
	[date_typesid] [int] IDENTITY(1,1) NOT NULL,
	[date_types] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[date_typesid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[delivery_days]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[delivery_days](
	[delivery_daysid] [int] IDENTITY(1,1) NOT NULL,
	[delivery_days] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[delivery_daysid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[deliverydays]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[deliverydays](
	[deliverydaysid] [int] IDENTITY(1,1) NOT NULL,
	[days] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[deliverydaysid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[designationmaster]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[designationmaster](
	[designationid] [int] IDENTITY(1,1) NOT NULL,
	[designation] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[designationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[django_admin_log]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_admin_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[action_time] [datetime2](7) NOT NULL,
	[object_id] [nvarchar](max) NULL,
	[object_repr] [nvarchar](200) NOT NULL,
	[action_flag] [smallint] NOT NULL,
	[change_message] [nvarchar](max) NOT NULL,
	[content_type_id] [int] NULL,
	[user_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[django_content_type]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_content_type](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app_label] [nvarchar](100) NOT NULL,
	[model] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [django_content_type_app_label_model_76bd3d3b_uniq] UNIQUE NONCLUSTERED 
(
	[app_label] ASC,
	[model] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[django_migrations]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_migrations](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[app] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[applied] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[django_session]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[django_session](
	[session_key] [nvarchar](40) NOT NULL,
	[session_data] [nvarchar](max) NOT NULL,
	[expire_date] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[session_key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[emaildetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[emaildetail](
	[emailid] [int] IDENTITY(1,1) NOT NULL,
	[requestdetail] [int] NULL,
	[emaildate] [datetime] NOT NULL,
	[stage] [varchar](max) NOT NULL,
	[emailsubject] [varchar](max) NOT NULL,
	[emailbody] [varchar](max) NOT NULL,
	[emailto] [varchar](max) NOT NULL,
	[emailfrom] [varchar](max) NOT NULL,
	[emailstatus] [varchar](255) NULL,
	[RequestStatus] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[emailid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[errorlog]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[errorlog](
	[error_id] [int] IDENTITY(1,1) NOT NULL,
	[errorlog_date] [datetime] NOT NULL,
	[error_occurancedate] [datetime] NOT NULL,
	[error_report] [int] NOT NULL,
	[error_reportedby] [int] NULL,
	[error_reportedto] [int] NOT NULL,
	[error_type] [int] NOT NULL,
	[error_description] [varchar](max) NOT NULL,
	[errordocument] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[error_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[errortype]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[errortype](
	[error_typeid] [int] IDENTITY(1,1) NOT NULL,
	[error_type] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[error_typeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[estimationdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[estimationdetail](
	[estimationid] [int] IDENTITY(1,1) NOT NULL,
	[estimationdate] [datetime] NOT NULL,
	[estimatedby] [int] NULL,
	[estimateddays] [int] NULL,
	[requestdetail] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[estimationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[feedback]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[feedback](
	[feedback_id] [int] IDENTITY(1,1) NOT NULL,
	[feedback_date] [datetime] NOT NULL,
	[feedback_question] [int] NOT NULL,
	[feedback_text] [varchar](255) NULL,
	[activity] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[feedback_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[feedback_question]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[feedback_question](
	[feedback_questionid] [int] IDENTITY(1,1) NOT NULL,
	[feedback_questiondate] [datetime] NOT NULL,
	[feedback_question] [varchar](255) NOT NULL,
	[feedback_answerdatatype] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[feedback_questionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[field_detail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[field_detail](
	[fieldid] [int] IDENTITY(1,1) NOT NULL,
	[tablename] [varchar](max) NOT NULL,
	[fieldname] [varchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[fieldid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[fielddetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[fielddetail](
	[fieldid] [int] IDENTITY(1,1) NOT NULL,
	[tablename] [varchar](255) NOT NULL,
	[fieldname] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[fieldid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[filteroption]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[filteroption](
	[filterid] [int] IDENTITY(1,1) NOT NULL,
	[filteroption] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[filterid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[frequency]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[frequency](
	[frequencyid] [int] IDENTITY(1,1) NOT NULL,
	[frequency] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[frequencyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Gallery]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Gallery](
	[imgid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[uploadedby] [int] NULL,
	[img] [varchar](255) NULL,
	[description] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[imgid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[governance]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[governance](
	[governancedatetime] [datetime] NOT NULL,
	[governanceid] [int] IDENTITY(1,1) NOT NULL,
	[teamdetail] [int] NOT NULL,
	[processimg] [varchar](100) NOT NULL,
	[description] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[governanceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[internaltask]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[internaltask](
	[internaltaskid] [int] IDENTITY(1,1) NOT NULL,
	[internaltaskdatetime] [datetime] NOT NULL,
	[internaltaskQuestion] [varchar](255) NOT NULL,
	[status] [int] NULL,
	[Owner] [int] NULL,
	[targetdate] [datetime] NULL,
	[link] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[internaltaskid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[internaltaskchoice]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[internaltaskchoice](
	[internaltaskchoiceid] [int] IDENTITY(1,1) NOT NULL,
	[internaltaskchoicedatetime] [datetime] NOT NULL,
	[internaltaskchoice] [varchar](255) NOT NULL,
	[internaltask] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[internaltaskchoiceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[internaltaskstatus]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[internaltaskstatus](
	[internaltaskstatusid] [int] IDENTITY(1,1) NOT NULL,
	[internaltaskstatusdatetime] [datetime] NOT NULL,
	[mimember] [int] NULL,
	[internaltask] [int] NULL,
	[internaltaskchoice] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[internaltaskstatusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Issue_Action]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Issue_Action](
	[Issue_Action_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[Issue] [varchar](255) NULL,
	[Action_taken] [varchar](255) NULL,
	[targetdate] [date] NULL,
	[updatedby] [int] NULL,
	[status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Issue_Action_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[managermaster]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[managermaster](
	[managerid] [int] IDENTITY(1,1) NOT NULL,
	[managername] [varchar](100) NULL,
	[employeeid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[managerid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[mimember]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[mimember](
	[mimemberid] [int] IDENTITY(1,1) NOT NULL,
	[username] [int] NOT NULL,
	[teamdetail] [int] NOT NULL,
	[designationmaster] [int] NULL,
	[employeeid] [int] NULL,
	[DateofJoining] [date] NULL,
	[DateofBirth] [date] NULL,
	[Address] [varchar](max) NULL,
	[PhoneNumber] [varchar](10) NULL,
	[Avatar] [varchar](255) NULL,
	[aboutme] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[mimemberid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[options]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[options](
	[optionsid] [int] IDENTITY(1,1) NOT NULL,
	[optionsname] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[optionsid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[optionsname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ot_detail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ot_detail](
	[ot_id] [int] IDENTITY(1,1) NOT NULL,
	[timetrackers] [int] NOT NULL,
	[ot_startdatetime] [datetime] NULL,
	[ot_enddatetime] [datetime] NULL,
	[ot_hrs] [int] NULL,
	[ot_status] [int] NOT NULL,
	[otdocument] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ot_status]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ot_status](
	[ot_statusid] [int] IDENTITY(1,1) NOT NULL,
	[ot_status] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ot_statusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[overviewdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[overviewdetail](
	[overviewid] [int] IDENTITY(1,1) NOT NULL,
	[overviewdate] [datetime] NOT NULL,
	[providedby] [int] NOT NULL,
	[mimember] [int] NULL,
	[sopcreatedoptionsid] [int] NULL,
	[requestdetail] [int] NOT NULL,
	[document] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[overviewid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[prioritydetail]    Script Date: 11/11/2018 12:20:24 PM ******/
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
/****** Object:  Table [dbo].[PublicHolidays]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PublicHolidays](
	[holidaysid] [int] IDENTITY(1,1) NOT NULL,
	[date] [date] NULL,
	[holidays_name] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[holidaysid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[reply]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[reply](
	[replydatetime] [datetime] NOT NULL,
	[replyid] [int] IDENTITY(1,1) NOT NULL,
	[mimember] [int] NULL,
	[reply] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[replyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[report_builder_displayfield]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_builder_displayfield](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[path] [nvarchar](2000) NOT NULL,
	[path_verbose] [nvarchar](2000) NOT NULL,
	[field] [nvarchar](2000) NOT NULL,
	[field_verbose] [nvarchar](2000) NOT NULL,
	[name] [nvarchar](2000) NOT NULL,
	[sort] [int] NULL,
	[sort_reverse] [bit] NOT NULL,
	[width] [int] NOT NULL,
	[aggregate] [nvarchar](5) NOT NULL,
	[position] [smallint] NULL,
	[total] [bit] NOT NULL,
	[group] [bit] NOT NULL,
	[display_format_id] [int] NULL,
	[report_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[report_builder_filterfield]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_builder_filterfield](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[path] [nvarchar](2000) NOT NULL,
	[path_verbose] [nvarchar](2000) NOT NULL,
	[field] [nvarchar](2000) NOT NULL,
	[field_verbose] [nvarchar](2000) NOT NULL,
	[filter_type] [nvarchar](20) NOT NULL,
	[filter_value] [nvarchar](2000) NOT NULL,
	[filter_value2] [nvarchar](2000) NOT NULL,
	[exclude] [bit] NOT NULL,
	[position] [smallint] NULL,
	[report_id] [int] NOT NULL,
	[filter_delta] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[report_builder_format]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_builder_format](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NOT NULL,
	[string] [nvarchar](300) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[report_builder_report]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_builder_report](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[slug] [nvarchar](50) NOT NULL,
	[description] [nvarchar](max) NOT NULL,
	[created] [date] NOT NULL,
	[modified] [date] NOT NULL,
	[distinct] [bit] NOT NULL,
	[report_file] [nvarchar](100) NOT NULL,
	[report_file_creation] [datetime2](7) NULL,
	[root_model_id] [int] NOT NULL,
	[user_created_id] [int] NULL,
	[user_modified_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[report_builder_report_starred]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_builder_report_starred](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[report_id] [int] NOT NULL,
	[user_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [report_builder_report_starred_report_id_user_id_8e38d9bd_uniq] UNIQUE NONCLUSTERED 
(
	[report_id] ASC,
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[report_calendar]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[report_calendar](
	[datecol] [datetime] NOT NULL,
	[calendar_days] [int] NOT NULL,
	[calendar_weeknum] [int] NOT NULL,
	[calendar_month] [int] NOT NULL,
	[calendar_days_rest] [int] NOT NULL,
	[working_days] [int] NOT NULL,
	[working_weeknum] [int] NOT NULL,
	[working_month] [int] NOT NULL,
	[working_days_rest] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[report_type]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_type](
	[report_typid] [int] IDENTITY(1,1) NOT NULL,
	[report_type] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[report_typid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[reports]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[reports](
	[reportid] [int] IDENTITY(1,1) NOT NULL,
	[registereddate] [datetime] NOT NULL,
	[name] [varchar](255) NULL,
	[frequency] [int] NULL,
	[deliverydays] [int] NULL,
	[deliverytime] [datetime] NOT NULL,
	[primaryowner] [int] NULL,
	[secondaryowner] [int] NULL,
	[description] [varchar](255) NULL,
	[delivery_time] [int] NULL,
	[report_type] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[reportid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[reports1]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[reports1](
	[reportid] [int] IDENTITY(1,1) NOT NULL,
	[registereddate] [datetime] NOT NULL,
	[name] [varchar](255) NULL,
	[frequency] [int] NULL,
	[date_types] [int] NULL,
	[delivery_days] [int] NULL,
	[deliverytime] [time](7) NOT NULL,
	[teamname] [int] NULL,
	[primaryowner] [int] NULL,
	[secondaryowner] [int] NULL,
	[description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[reportid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[requestcategorys]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[requestcategorys](
	[requestcategoryid] [int] IDENTITY(1,1) NOT NULL,
	[requestcategorydatetime] [datetime] NOT NULL,
	[requestcategorys] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[requestcategoryid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[requestdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[requestdetail](
	[requestid] [int] IDENTITY(1,1) NOT NULL,
	[requestraiseddate] [datetime] NOT NULL,
	[requesttypedetail] [int] NOT NULL,
	[prioritydetail] [int] NOT NULL,
	[username] [int] NOT NULL,
	[requestdescription] [varchar](max) NOT NULL,
	[requestdocument] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[requestid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[requeststatusdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[requeststatusdetail](
	[requeststatusid] [int] IDENTITY(1,1) NOT NULL,
	[requeststatusdate] [datetime] NOT NULL,
	[username] [int] NOT NULL,
	[statusdetail] [int] NULL,
	[requestdetail] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[requeststatusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[requestsubcategory]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[requestsubcategory](
	[requestsubcategoryid] [int] IDENTITY(1,1) NOT NULL,
	[requestsubcategorydatetime] [datetime] NOT NULL,
	[requestcategorys] [int] NULL,
	[requestsubcategory] [varchar](100) NULL,
	[core_noncore] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[requestsubcategoryid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[requesttypedetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[requesttypedetail](
	[requesttypeid] [int] IDENTITY(1,1) NOT NULL,
	[requesttype] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[requesttypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[requesttype] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ShiftUpdate]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ShiftUpdate](
	[updateid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[updateinbrief] [varchar](max) NULL,
	[updatedrecordedby] [int] NULL,
	[updatestatus] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[updateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[statusdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[statusdetail](
	[statusnameid] [int] IDENTITY(1,1) NOT NULL,
	[statusname] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[statusnameid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[statusname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[success_stories]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[success_stories](
	[storiesdatetime] [datetime] NOT NULL,
	[storiesid] [int] IDENTITY(1,1) NOT NULL,
	[stories] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[storiesid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[suggestion]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[suggestion](
	[suggestiondatetime] [datetime] NOT NULL,
	[suggestionid] [int] IDENTITY(1,1) NOT NULL,
	[suggestion] [varchar](max) NOT NULL,
	[subject] [varchar](100) NULL,
	[suggestedby] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[suggestionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Appreciation]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Appreciation](
	[Appreciationid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[Appreciated_to] [int] NULL,
	[Appreciated_by] [varchar](100) NULL,
	[Description] [varchar](255) NULL,
	[appreciation_status] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Appreciationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_Calendar]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Calendar](
	[date] [date] NULL,
	[Days Type] [varchar](50) NULL,
	[Daily] [int] NULL,
	[Weekly] [int] NULL,
	[Monthly] [int] NULL,
	[FIrstDayofmonth] [date] NULL,
	[LastDayoftheMonth] [date] NULL,
	[WeekNum] [int] NULL,
	[WeekName] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_conversation]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_conversation](
	[conversationid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[requestdetail] [int] NOT NULL,
	[userid] [int] NOT NULL,
	[comments] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[conversationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_leave_record]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_leave_record](
	[leaverecordid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[leave_date] [date] NOT NULL,
	[userid] [int] NOT NULL,
	[leave_type] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[leaverecordid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_leave_type]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_leave_type](
	[leavetypeid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[leave_type] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[leavetypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_navbar_footer_master]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_navbar_footer_master](
	[navbar_footer_id] [int] IDENTITY(1,1) NOT NULL,
	[navbar_footer_name] [varchar](255) NULL,
	[navbar_header_url] [varchar](255) NULL,
	[ranking] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[navbar_footer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_navbar_header_master]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_navbar_header_master](
	[navbar_header_id] [int] IDENTITY(1,1) NOT NULL,
	[navbar_header_name] [varchar](255) NULL,
	[navbar_header_url] [varchar](255) NULL,
	[ranking] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[navbar_header_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_navbar_master]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_navbar_master](
	[navbar_id] [int] IDENTITY(1,1) NOT NULL,
	[group_name] [int] NOT NULL,
	[navbar_header_id] [int] NOT NULL,
	[navbar_footer_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[navbar_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_navbar_view]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_navbar_view](
	[navbar_id] [int] IDENTITY(1,1) NOT NULL,
	[view_type] [int] NOT NULL,
	[navbar_header_id] [int] NOT NULL,
	[navbar_footer_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[navbar_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_raw_activity_detail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_raw_activity_detail](
	[raw_activity_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[raw_activity] [varchar](50) NULL,
	[raw_activity_description] [varchar](max) NULL,
	[raw_activity_img] [varchar](255) NULL,
	[raw_activity_scheduled] [date] NULL,
	[raw_activitystatus] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[raw_activity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_raw_score]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_raw_score](
	[raw_score_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[raw_team] [int] NULL,
	[score] [int] NULL,
	[Winner] [varchar](50) NULL,
	[description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[raw_score_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_raw_team_master]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_raw_team_master](
	[raw_team_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[raw_team] [varchar](255) NULL,
	[raw_team_icon] [varchar](255) NULL,
	[raw_team_slogan] [varchar](255) NULL,
	[valid_invalid] [int] NULL,
	[raw_management] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[raw_team_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_raw_team_member_master]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_raw_team_member_master](
	[raw_team_member_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[raw_team] [int] NULL,
	[raw_member] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[raw_team_member_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_team_metrics]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_team_metrics](
	[metrics_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[metrics_name] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[metrics_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_useful_links]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_useful_links](
	[linkid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[teamdetail] [int] NULL,
	[mimember] [int] NULL,
	[link] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[linkid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[team_metrics]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[team_metrics](
	[metrics_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[teamdetail] [int] NULL,
	[metrics_name] [int] NULL,
	[requesttype] [int] NULL,
	[description] [varchar](255) NULL,
	[volume] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[metrics_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[team_metrics_data]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[team_metrics_data](
	[metrics_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[teamdetail] [int] NULL,
	[requesttype] [int] NULL,
	[Total] [int] NULL,
	[WIP] [int] NULL,
	[UAT] [int] NULL,
	[Completed] [int] NULL,
	[Project] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[metrics_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[teamdetail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[teamdetail](
	[teamid] [int] IDENTITY(1,1) NOT NULL,
	[teamdatetime] [datetime] NOT NULL,
	[teamname] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[teamid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[time_detail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[time_detail](
	[timeid] [int] IDENTITY(1,1) NOT NULL,
	[time] [varchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[timeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[timetrackers]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[timetrackers](
	[timetrackerid] [int] IDENTITY(1,1) NOT NULL,
	[registerdatetime] [datetime] NOT NULL,
	[trackingdatetime] [date] NOT NULL,
	[mimember] [int] NULL,
	[teamdetail] [int] NULL,
	[requestcategorys] [int] NULL,
	[requestsubcategory] [int] NULL,
	[task] [varchar](100) NULL,
	[requestdetail] [int] NULL,
	[description_text] [varchar](255) NULL,
	[totaltime] [int] NULL,
	[comments] [varchar](255) NULL,
	[startdatetime] [datetime] NULL,
	[stopdatetime] [datetime] NULL,
	[reports] [int] NULL,
	[ot] [int] NULL,
	[valid_invalid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[timetrackerid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tl_master]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tl_master](
	[tl_id] [int] IDENTITY(1,1) NOT NULL,
	[tl_name] [varchar](100) NULL,
	[employeeid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[tl_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UAT_detail]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UAT_detail](
	[uatid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[UAT_status] [int] NULL,
	[requestdetail] [int] NOT NULL,
	[testedby] [int] NULL,
	[updatedby] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[uatid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UAT_status]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UAT_status](
	[UAT_status_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[UAT_status] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[UAT_status_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[valid_invalid]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[valid_invalid](
	[valid_invaidid] [int] IDENTITY(1,1) NOT NULL,
	[type] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[valid_invaidid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[view_type]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[view_type](
	[view_id] [int] IDENTITY(1,1) NOT NULL,
	[viewname] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[view_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[whatwedo]    Script Date: 11/11/2018 12:20:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[whatwedo](
	[recordid] [int] IDENTITY(1,1) NOT NULL,
	[Data] [varchar](255) NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[Type] [varchar](100) NOT NULL,
	[Image] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[recordid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Index [auth_group_permissions_group_id_b120cbf9]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_group_id_b120cbf9] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_permission_id_84c5c92e]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_permission_id_84c5c92e] ON [dbo].[auth_group_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_permission_content_type_id_2f476e4b]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_permission_content_type_id_2f476e4b] ON [dbo].[auth_permission]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_groups_group_id_97559544]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_groups_group_id_97559544] ON [dbo].[auth_user_groups]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_groups_user_id_6a12ed8b]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_groups_user_id_6a12ed8b] ON [dbo].[auth_user_groups]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_user_permissions_permission_id_1fbb5f2c]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_user_permissions_permission_id_1fbb5f2c] ON [dbo].[auth_user_user_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_user_permissions_user_id_a95ead1b]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_user_permissions_user_id_a95ead1b] ON [dbo].[auth_user_user_permissions]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_content_type_id_c4bce8eb]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [django_admin_log_content_type_id_c4bce8eb] ON [dbo].[django_admin_log]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_user_id_c564eba6]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [django_admin_log_user_id_c564eba6] ON [dbo].[django_admin_log]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_session_expire_date_a5c62663]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [django_session_expire_date_a5c62663] ON [dbo].[django_session]
(
	[expire_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_displayfield_display_format_id_c649f0ea]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_displayfield_display_format_id_c649f0ea] ON [dbo].[report_builder_displayfield]
(
	[display_format_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_displayfield_report_id_642d3d44]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_displayfield_report_id_642d3d44] ON [dbo].[report_builder_displayfield]
(
	[report_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_filterfield_report_id_a5498074]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_filterfield_report_id_a5498074] ON [dbo].[report_builder_filterfield]
(
	[report_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_report_root_model_id_3bae34b3]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_report_root_model_id_3bae34b3] ON [dbo].[report_builder_report]
(
	[root_model_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [report_builder_report_slug_559601ba]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_report_slug_559601ba] ON [dbo].[report_builder_report]
(
	[slug] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_report_user_created_id_e8133ae8]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_report_user_created_id_e8133ae8] ON [dbo].[report_builder_report]
(
	[user_created_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_report_user_modified_id_04e38ffb]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_report_user_modified_id_04e38ffb] ON [dbo].[report_builder_report]
(
	[user_modified_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_report_starred_report_id_0a54a683]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_report_starred_report_id_0a54a683] ON [dbo].[report_builder_report_starred]
(
	[report_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [report_builder_report_starred_user_id_70388cb5]    Script Date: 11/11/2018 12:20:24 PM ******/
CREATE NONCLUSTERED INDEX [report_builder_report_starred_user_id_70388cb5] ON [dbo].[report_builder_report_starred]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[acceptrejectdetail] ADD  DEFAULT (getdate()) FOR [estacceptrejectdate]
GO
ALTER TABLE [dbo].[activity] ADD  DEFAULT (getdate()) FOR [registereddate]
GO
ALTER TABLE [dbo].[activitystatus_calendar] ADD  DEFAULT (getdate()) FOR [activitystatusdate]
GO
ALTER TABLE [dbo].[assigneddetail] ADD  DEFAULT (getdate()) FOR [assignedDate]
GO
ALTER TABLE [dbo].[authorisedetail] ADD  DEFAULT (getdate()) FOR [authoriseddate]
GO
ALTER TABLE [dbo].[completeddetail] ADD  DEFAULT (getdate()) FOR [completeddate]
GO
ALTER TABLE [dbo].[emaildetail] ADD  DEFAULT (getdate()) FOR [emaildate]
GO
ALTER TABLE [dbo].[errorlog] ADD  DEFAULT (getdate()) FOR [errorlog_date]
GO
ALTER TABLE [dbo].[estimationdetail] ADD  DEFAULT (getdate()) FOR [estimationdate]
GO
ALTER TABLE [dbo].[feedback] ADD  DEFAULT (getdate()) FOR [feedback_date]
GO
ALTER TABLE [dbo].[feedback_question] ADD  DEFAULT (getdate()) FOR [feedback_questiondate]
GO
ALTER TABLE [dbo].[Gallery] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[governance] ADD  DEFAULT (getdate()) FOR [governancedatetime]
GO
ALTER TABLE [dbo].[internaltask] ADD  DEFAULT (getdate()) FOR [internaltaskdatetime]
GO
ALTER TABLE [dbo].[internaltaskchoice] ADD  DEFAULT (getdate()) FOR [internaltaskchoicedatetime]
GO
ALTER TABLE [dbo].[internaltaskstatus] ADD  DEFAULT (getdate()) FOR [internaltaskstatusdatetime]
GO
ALTER TABLE [dbo].[Issue_Action] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[overviewdetail] ADD  DEFAULT (getdate()) FOR [overviewdate]
GO
ALTER TABLE [dbo].[reply] ADD  DEFAULT (getdate()) FOR [replydatetime]
GO
ALTER TABLE [dbo].[reports] ADD  DEFAULT (getdate()) FOR [registereddate]
GO
ALTER TABLE [dbo].[reports] ADD  DEFAULT (getdate()) FOR [deliverytime]
GO
ALTER TABLE [dbo].[reports1] ADD  DEFAULT (getdate()) FOR [registereddate]
GO
ALTER TABLE [dbo].[requestcategorys] ADD  DEFAULT (getdate()) FOR [requestcategorydatetime]
GO
ALTER TABLE [dbo].[requestdetail] ADD  DEFAULT (getdate()) FOR [requestraiseddate]
GO
ALTER TABLE [dbo].[requeststatusdetail] ADD  DEFAULT (getdate()) FOR [requeststatusdate]
GO
ALTER TABLE [dbo].[requestsubcategory] ADD  DEFAULT (getdate()) FOR [requestsubcategorydatetime]
GO
ALTER TABLE [dbo].[ShiftUpdate] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[success_stories] ADD  DEFAULT (getdate()) FOR [storiesdatetime]
GO
ALTER TABLE [dbo].[suggestion] ADD  DEFAULT (getdate()) FOR [suggestiondatetime]
GO
ALTER TABLE [dbo].[tbl_Appreciation] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_conversation] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_leave_record] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_leave_type] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_activity_detail] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_score] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_team_master] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_team_member_master] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_team_metrics] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_useful_links] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[team_metrics] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[team_metrics_data] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[teamdetail] ADD  DEFAULT (getdate()) FOR [teamdatetime]
GO
ALTER TABLE [dbo].[timetrackers] ADD  DEFAULT (getdate()) FOR [registerdatetime]
GO
ALTER TABLE [dbo].[timetrackers] ADD  DEFAULT (getdate()) FOR [trackingdatetime]
GO
ALTER TABLE [dbo].[timetrackers] ADD  DEFAULT (getdate()) FOR [startdatetime]
GO
ALTER TABLE [dbo].[timetrackers] ADD  DEFAULT (getdate()) FOR [stopdatetime]
GO
ALTER TABLE [dbo].[UAT_detail] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[UAT_status] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[acceptrejectdetail]  WITH CHECK ADD FOREIGN KEY([estacceptrejectby])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[acceptrejectdetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([activitystatus])
REFERENCES [dbo].[activitystatus] ([activitystatusid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([date_types])
REFERENCES [dbo].[date_types] ([date_typesid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([frequency])
REFERENCES [dbo].[frequency] ([frequencyid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([primaryowner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([requestcategorys])
REFERENCES [dbo].[requestcategorys] ([requestcategoryid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([secondaryowner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[activity]  WITH CHECK ADD FOREIGN KEY([teamname])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([activitystatus])
REFERENCES [dbo].[statusdetail] ([statusnameid])
GO
ALTER TABLE [dbo].[activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([activityid])
REFERENCES [dbo].[activity] ([activityid])
GO
ALTER TABLE [dbo].[activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([reallocatedto])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([recordenteredby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[assign_view]  WITH CHECK ADD FOREIGN KEY([group_name])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[assign_view]  WITH CHECK ADD FOREIGN KEY([view_type])
REFERENCES [dbo].[view_type] ([view_id])
GO
ALTER TABLE [dbo].[assigneddetail]  WITH CHECK ADD FOREIGN KEY([assignedto])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[assigneddetail]  WITH CHECK ADD FOREIGN KEY([assignedby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[assigneddetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_group_id_b120cbf9_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_group_permissions]  WITH CHECK ADD  CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_group_permissions] CHECK CONSTRAINT [auth_group_permissions_permission_id_84c5c92e_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_permission]  WITH CHECK ADD  CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[auth_permission] CHECK CONSTRAINT [auth_permission_content_type_id_2f476e4b_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[auth_user_groups]  WITH CHECK ADD  CONSTRAINT [auth_user_groups_group_id_97559544_fk_auth_group_id] FOREIGN KEY([group_id])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[auth_user_groups] CHECK CONSTRAINT [auth_user_groups_group_id_97559544_fk_auth_group_id]
GO
ALTER TABLE [dbo].[auth_user_groups]  WITH CHECK ADD  CONSTRAINT [auth_user_groups_user_id_6a12ed8b_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[auth_user_groups] CHECK CONSTRAINT [auth_user_groups_user_id_6a12ed8b_fk_auth_user_id]
GO
ALTER TABLE [dbo].[auth_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [auth_user_user_permissions_permission_id_1fbb5f2c_fk_auth_permission_id] FOREIGN KEY([permission_id])
REFERENCES [dbo].[auth_permission] ([id])
GO
ALTER TABLE [dbo].[auth_user_user_permissions] CHECK CONSTRAINT [auth_user_user_permissions_permission_id_1fbb5f2c_fk_auth_permission_id]
GO
ALTER TABLE [dbo].[auth_user_user_permissions]  WITH CHECK ADD  CONSTRAINT [auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[auth_user_user_permissions] CHECK CONSTRAINT [auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id]
GO
ALTER TABLE [dbo].[authorisedetail]  WITH CHECK ADD FOREIGN KEY([authoriserdetail])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[authorisedetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[authoriserdetail]  WITH CHECK ADD FOREIGN KEY([username])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[completeddetail]  WITH CHECK ADD FOREIGN KEY([completedby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[completeddetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id] FOREIGN KEY([content_type_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_content_type_id_c4bce8eb_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_user_id_c564eba6_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_user_id_c564eba6_fk_auth_user_id]
GO
ALTER TABLE [dbo].[emaildetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[errorlog]  WITH CHECK ADD FOREIGN KEY([error_reportedby])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[errorlog]  WITH CHECK ADD FOREIGN KEY([error_type])
REFERENCES [dbo].[errortype] ([error_typeid])
GO
ALTER TABLE [dbo].[errorlog]  WITH CHECK ADD FOREIGN KEY([error_reportedto])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[errorlog]  WITH CHECK ADD FOREIGN KEY([error_type])
REFERENCES [dbo].[errortype] ([error_typeid])
GO
ALTER TABLE [dbo].[errorlog]  WITH CHECK ADD FOREIGN KEY([error_report])
REFERENCES [dbo].[activity] ([activityid])
GO
ALTER TABLE [dbo].[estimationdetail]  WITH CHECK ADD FOREIGN KEY([estimatedby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[estimationdetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[feedback]  WITH CHECK ADD FOREIGN KEY([activity])
REFERENCES [dbo].[activity] ([activityid])
GO
ALTER TABLE [dbo].[feedback]  WITH CHECK ADD FOREIGN KEY([feedback_question])
REFERENCES [dbo].[feedback_question] ([feedback_questionid])
GO
ALTER TABLE [dbo].[Gallery]  WITH CHECK ADD FOREIGN KEY([uploadedby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[governance]  WITH CHECK ADD FOREIGN KEY([teamdetail])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[internaltask]  WITH CHECK ADD FOREIGN KEY([Owner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[internaltask]  WITH CHECK ADD FOREIGN KEY([status])
REFERENCES [dbo].[activitystatus] ([activitystatusid])
GO
ALTER TABLE [dbo].[internaltaskchoice]  WITH CHECK ADD FOREIGN KEY([internaltask])
REFERENCES [dbo].[internaltask] ([internaltaskid])
GO
ALTER TABLE [dbo].[internaltaskstatus]  WITH CHECK ADD FOREIGN KEY([internaltask])
REFERENCES [dbo].[internaltask] ([internaltaskid])
GO
ALTER TABLE [dbo].[internaltaskstatus]  WITH CHECK ADD FOREIGN KEY([internaltaskchoice])
REFERENCES [dbo].[internaltaskchoice] ([internaltaskchoiceid])
GO
ALTER TABLE [dbo].[internaltaskstatus]  WITH CHECK ADD FOREIGN KEY([mimember])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[Issue_Action]  WITH CHECK ADD FOREIGN KEY([status])
REFERENCES [dbo].[activitystatus] ([activitystatusid])
GO
ALTER TABLE [dbo].[Issue_Action]  WITH CHECK ADD FOREIGN KEY([updatedby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[mimember]  WITH CHECK ADD FOREIGN KEY([designationmaster])
REFERENCES [dbo].[designationmaster] ([designationid])
GO
ALTER TABLE [dbo].[mimember]  WITH CHECK ADD FOREIGN KEY([username])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[ot_detail]  WITH CHECK ADD FOREIGN KEY([ot_status])
REFERENCES [dbo].[ot_status] ([ot_statusid])
GO
ALTER TABLE [dbo].[ot_detail]  WITH CHECK ADD FOREIGN KEY([timetrackers])
REFERENCES [dbo].[timetrackers] ([timetrackerid])
GO
ALTER TABLE [dbo].[overviewdetail]  WITH CHECK ADD FOREIGN KEY([mimember])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[overviewdetail]  WITH CHECK ADD FOREIGN KEY([providedby])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[overviewdetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[overviewdetail]  WITH CHECK ADD FOREIGN KEY([sopcreatedoptionsid])
REFERENCES [dbo].[options] ([optionsid])
GO
ALTER TABLE [dbo].[reply]  WITH CHECK ADD FOREIGN KEY([mimember])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[report_builder_displayfield]  WITH CHECK ADD  CONSTRAINT [report_builder_displayfield_display_format_id_c649f0ea_fk_report_builder_format_id] FOREIGN KEY([display_format_id])
REFERENCES [dbo].[report_builder_format] ([id])
GO
ALTER TABLE [dbo].[report_builder_displayfield] CHECK CONSTRAINT [report_builder_displayfield_display_format_id_c649f0ea_fk_report_builder_format_id]
GO
ALTER TABLE [dbo].[report_builder_displayfield]  WITH CHECK ADD  CONSTRAINT [report_builder_displayfield_report_id_642d3d44_fk_report_builder_report_id] FOREIGN KEY([report_id])
REFERENCES [dbo].[report_builder_report] ([id])
GO
ALTER TABLE [dbo].[report_builder_displayfield] CHECK CONSTRAINT [report_builder_displayfield_report_id_642d3d44_fk_report_builder_report_id]
GO
ALTER TABLE [dbo].[report_builder_filterfield]  WITH CHECK ADD  CONSTRAINT [report_builder_filterfield_report_id_a5498074_fk_report_builder_report_id] FOREIGN KEY([report_id])
REFERENCES [dbo].[report_builder_report] ([id])
GO
ALTER TABLE [dbo].[report_builder_filterfield] CHECK CONSTRAINT [report_builder_filterfield_report_id_a5498074_fk_report_builder_report_id]
GO
ALTER TABLE [dbo].[report_builder_report]  WITH CHECK ADD  CONSTRAINT [report_builder_report_root_model_id_3bae34b3_fk_django_content_type_id] FOREIGN KEY([root_model_id])
REFERENCES [dbo].[django_content_type] ([id])
GO
ALTER TABLE [dbo].[report_builder_report] CHECK CONSTRAINT [report_builder_report_root_model_id_3bae34b3_fk_django_content_type_id]
GO
ALTER TABLE [dbo].[report_builder_report]  WITH CHECK ADD  CONSTRAINT [report_builder_report_user_created_id_e8133ae8_fk_auth_user_id] FOREIGN KEY([user_created_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[report_builder_report] CHECK CONSTRAINT [report_builder_report_user_created_id_e8133ae8_fk_auth_user_id]
GO
ALTER TABLE [dbo].[report_builder_report]  WITH CHECK ADD  CONSTRAINT [report_builder_report_user_modified_id_04e38ffb_fk_auth_user_id] FOREIGN KEY([user_modified_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[report_builder_report] CHECK CONSTRAINT [report_builder_report_user_modified_id_04e38ffb_fk_auth_user_id]
GO
ALTER TABLE [dbo].[report_builder_report_starred]  WITH CHECK ADD  CONSTRAINT [report_builder_report_starred_report_id_0a54a683_fk_report_builder_report_id] FOREIGN KEY([report_id])
REFERENCES [dbo].[report_builder_report] ([id])
GO
ALTER TABLE [dbo].[report_builder_report_starred] CHECK CONSTRAINT [report_builder_report_starred_report_id_0a54a683_fk_report_builder_report_id]
GO
ALTER TABLE [dbo].[report_builder_report_starred]  WITH CHECK ADD  CONSTRAINT [report_builder_report_starred_user_id_70388cb5_fk_auth_user_id] FOREIGN KEY([user_id])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[report_builder_report_starred] CHECK CONSTRAINT [report_builder_report_starred_user_id_70388cb5_fk_auth_user_id]
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD FOREIGN KEY([deliverydays])
REFERENCES [dbo].[deliverydays] ([deliverydaysid])
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD FOREIGN KEY([delivery_time])
REFERENCES [dbo].[time_detail] ([timeid])
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD FOREIGN KEY([frequency])
REFERENCES [dbo].[frequency] ([frequencyid])
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD FOREIGN KEY([primaryowner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD FOREIGN KEY([report_type])
REFERENCES [dbo].[report_type] ([report_typid])
GO
ALTER TABLE [dbo].[reports]  WITH CHECK ADD FOREIGN KEY([secondaryowner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[reports1]  WITH CHECK ADD FOREIGN KEY([date_types])
REFERENCES [dbo].[date_types] ([date_typesid])
GO
ALTER TABLE [dbo].[reports1]  WITH CHECK ADD FOREIGN KEY([frequency])
REFERENCES [dbo].[frequency] ([frequencyid])
GO
ALTER TABLE [dbo].[reports1]  WITH CHECK ADD FOREIGN KEY([primaryowner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[reports1]  WITH CHECK ADD FOREIGN KEY([secondaryowner])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[reports1]  WITH CHECK ADD FOREIGN KEY([teamname])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[requestdetail]  WITH CHECK ADD FOREIGN KEY([prioritydetail])
REFERENCES [dbo].[prioritydetail] ([requestpriorityid])
GO
ALTER TABLE [dbo].[requestdetail]  WITH CHECK ADD FOREIGN KEY([requesttypedetail])
REFERENCES [dbo].[requesttypedetail] ([requesttypeid])
GO
ALTER TABLE [dbo].[requestdetail]  WITH CHECK ADD FOREIGN KEY([username])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[requeststatusdetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[requeststatusdetail]  WITH CHECK ADD FOREIGN KEY([statusdetail])
REFERENCES [dbo].[statusdetail] ([statusnameid])
GO
ALTER TABLE [dbo].[requeststatusdetail]  WITH CHECK ADD FOREIGN KEY([username])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[requestsubcategory]  WITH CHECK ADD FOREIGN KEY([requestcategorys])
REFERENCES [dbo].[requestcategorys] ([requestcategoryid])
GO
ALTER TABLE [dbo].[ShiftUpdate]  WITH CHECK ADD FOREIGN KEY([updatedrecordedby])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[ShiftUpdate]  WITH CHECK ADD FOREIGN KEY([updatestatus])
REFERENCES [dbo].[activitystatus] ([activitystatusid])
GO
ALTER TABLE [dbo].[suggestion]  WITH CHECK ADD FOREIGN KEY([suggestedby])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_Appreciation]  WITH CHECK ADD FOREIGN KEY([Appreciated_to])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[tbl_Appreciation]  WITH CHECK ADD FOREIGN KEY([appreciation_status])
REFERENCES [dbo].[activitystatus] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_conversation]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_conversation]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_leave_record]  WITH CHECK ADD FOREIGN KEY([leave_type])
REFERENCES [dbo].[tbl_leave_type] ([leavetypeid])
GO
ALTER TABLE [dbo].[tbl_leave_record]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[tbl_navbar_master]  WITH CHECK ADD FOREIGN KEY([group_name])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[tbl_navbar_master]  WITH CHECK ADD FOREIGN KEY([navbar_header_id])
REFERENCES [dbo].[tbl_navbar_header_master] ([navbar_header_id])
GO
ALTER TABLE [dbo].[tbl_navbar_master]  WITH CHECK ADD FOREIGN KEY([navbar_footer_id])
REFERENCES [dbo].[tbl_navbar_footer_master] ([navbar_footer_id])
GO
ALTER TABLE [dbo].[tbl_navbar_view]  WITH CHECK ADD FOREIGN KEY([navbar_header_id])
REFERENCES [dbo].[tbl_navbar_header_master] ([navbar_header_id])
GO
ALTER TABLE [dbo].[tbl_navbar_view]  WITH CHECK ADD FOREIGN KEY([navbar_footer_id])
REFERENCES [dbo].[tbl_navbar_footer_master] ([navbar_footer_id])
GO
ALTER TABLE [dbo].[tbl_navbar_view]  WITH CHECK ADD FOREIGN KEY([view_type])
REFERENCES [dbo].[view_type] ([view_id])
GO
ALTER TABLE [dbo].[tbl_raw_activity_detail]  WITH CHECK ADD FOREIGN KEY([raw_activitystatus])
REFERENCES [dbo].[activitystatus] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_raw_score]  WITH CHECK ADD FOREIGN KEY([raw_team])
REFERENCES [dbo].[tbl_raw_team_master] ([raw_team_id])
GO
ALTER TABLE [dbo].[tbl_raw_team_master]  WITH CHECK ADD FOREIGN KEY([raw_management])
REFERENCES [dbo].[options] ([optionsid])
GO
ALTER TABLE [dbo].[tbl_raw_team_master]  WITH CHECK ADD FOREIGN KEY([valid_invalid])
REFERENCES [dbo].[valid_invalid] ([valid_invaidid])
GO
ALTER TABLE [dbo].[tbl_raw_team_member_master]  WITH CHECK ADD FOREIGN KEY([raw_member])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[tbl_raw_team_member_master]  WITH CHECK ADD FOREIGN KEY([raw_team])
REFERENCES [dbo].[tbl_raw_team_master] ([raw_team_id])
GO
ALTER TABLE [dbo].[tbl_useful_links]  WITH CHECK ADD FOREIGN KEY([mimember])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[tbl_useful_links]  WITH CHECK ADD FOREIGN KEY([teamdetail])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[team_metrics]  WITH CHECK ADD FOREIGN KEY([metrics_name])
REFERENCES [dbo].[tbl_team_metrics] ([metrics_id])
GO
ALTER TABLE [dbo].[team_metrics]  WITH CHECK ADD FOREIGN KEY([requesttype])
REFERENCES [dbo].[requesttypedetail] ([requesttypeid])
GO
ALTER TABLE [dbo].[team_metrics]  WITH CHECK ADD FOREIGN KEY([teamdetail])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[team_metrics_data]  WITH CHECK ADD FOREIGN KEY([requesttype])
REFERENCES [dbo].[requesttypedetail] ([requesttypeid])
GO
ALTER TABLE [dbo].[team_metrics_data]  WITH CHECK ADD FOREIGN KEY([teamdetail])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([mimember])
REFERENCES [dbo].[mimember] ([mimemberid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([reports])
REFERENCES [dbo].[activity] ([activityid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([requestcategorys])
REFERENCES [dbo].[requestcategorys] ([requestcategoryid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([requestsubcategory])
REFERENCES [dbo].[requestsubcategory] ([requestsubcategoryid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([teamdetail])
REFERENCES [dbo].[teamdetail] ([teamid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([valid_invalid])
REFERENCES [dbo].[valid_invalid] ([valid_invaidid])
GO
ALTER TABLE [dbo].[timetrackers]  WITH CHECK ADD FOREIGN KEY([ot])
REFERENCES [dbo].[ot_detail] ([ot_id])
GO
ALTER TABLE [dbo].[UAT_detail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[UAT_detail]  WITH CHECK ADD FOREIGN KEY([testedby])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[UAT_detail]  WITH CHECK ADD FOREIGN KEY([UAT_status])
REFERENCES [dbo].[UAT_status] ([UAT_status_id])
GO
ALTER TABLE [dbo].[UAT_detail]  WITH CHECK ADD FOREIGN KEY([updatedby])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_action_flag_a8637d59_check] CHECK  (([action_flag]>=(0)))
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_action_flag_a8637d59_check]
GO
ALTER TABLE [dbo].[report_builder_displayfield]  WITH CHECK ADD  CONSTRAINT [report_builder_displayfield_position_f4e0aa5c_check] CHECK  (([position]>=(0)))
GO
ALTER TABLE [dbo].[report_builder_displayfield] CHECK CONSTRAINT [report_builder_displayfield_position_f4e0aa5c_check]
GO
ALTER TABLE [dbo].[report_builder_filterfield]  WITH CHECK ADD  CONSTRAINT [report_builder_filterfield_position_37e3ef58_check] CHECK  (([position]>=(0)))
GO
ALTER TABLE [dbo].[report_builder_filterfield] CHECK CONSTRAINT [report_builder_filterfield_position_37e3ef58_check]
GO
USE [master]
GO
ALTER DATABASE [CentralMI] SET  READ_WRITE 
GO
