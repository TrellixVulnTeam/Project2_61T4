USE [master]
GO
/****** Object:  Database [SDPM_team]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE DATABASE [SDPM_team]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CentralMI', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\CentralMI.mdf' , SIZE = 68608KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'CentralMI_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\CentralMI_log.ldf' , SIZE = 2304KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [SDPM_team] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SDPM_team].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SDPM_team] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SDPM_team] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SDPM_team] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SDPM_team] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SDPM_team] SET ARITHABORT OFF 
GO
ALTER DATABASE [SDPM_team] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SDPM_team] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SDPM_team] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SDPM_team] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SDPM_team] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SDPM_team] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SDPM_team] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SDPM_team] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SDPM_team] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SDPM_team] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SDPM_team] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SDPM_team] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SDPM_team] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SDPM_team] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SDPM_team] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SDPM_team] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SDPM_team] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SDPM_team] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SDPM_team] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SDPM_team] SET  MULTI_USER 
GO
ALTER DATABASE [SDPM_team] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SDPM_team] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SDPM_team] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SDPM_team] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [SDPM_team]
GO
/****** Object:  User [test]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE USER [test] FOR LOGIN [test] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [djangoapp]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE USER [djangoapp] FOR LOGIN [djangoapp] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  StoredProcedure [dbo].[usp_activity_calendar]    Script Date: 11/24/2018 1:25:23 PM ******/
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
  FROM [SDPM_team].[dbo].[activity_calendar] A
  Left Join [SDPM_team].[dbo].[activity] B on A.[activityid] = B.[activityid]
  Left Join [SDPM_team].[dbo].[activitystatus_calendar] C on B.[activityid] = C.[activityid]
  Left Join [SDPM_team].[dbo].[teamdetail] D on B.teamname = D.teamid
  Left Join  [SDPM_team].[dbo].[activitystatus] G on B.activitystatus = G.activitystatusid
  Left Join  [SDPM_team].[dbo].[statusdetail] H on C.activitystatus = H.statusnameid

 where A.date in (@inputdate)
  and A.frequency in (@inputfreq)
  and G.activitystatus not in ('Closed')
  and  (H.statusname not in ('Completed','Rejected') or H.statusname  is null) 

  
GO
/****** Object:  StoredProcedure [dbo].[uspjoin]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[auth_group]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[auth_group_permissions]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[auth_permission]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[auth_user]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[auth_user_groups]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[auth_user_user_permissions]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[calendar]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[calendar](
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
/****** Object:  Table [dbo].[django_admin_log]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[django_content_type]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[django_migrations]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[django_session]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_acceptrejectdetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_acceptrejectdetail](
	[estacceptrejectid] [int] IDENTITY(1,1) NOT NULL,
	[estacceptrejectdate] [datetime] NOT NULL,
	[userid] [int] NOT NULL,
	[requestid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[estacceptrejectid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_activity]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_activity](
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
/****** Object:  Table [dbo].[tbl_activity_calendar]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_activity_calendar](
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
/****** Object:  Table [dbo].[tbl_activitystatus_calendar]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_activitystatus_calendar](
	[activitystatuscalendarid] [int] IDENTITY(1,1) NOT NULL,
	[activitystatusdate] [datetime] NOT NULL,
	[activitystatus] [int] NULL,
	[activityid] [int] NULL,
	[activitycalendardate] [date] NULL,
	[reallocatedtoid] [int] NULL,
	[recordenteredbyid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[activitystatuscalendarid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_appreciation]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_appreciation](
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
/****** Object:  Table [dbo].[tbl_assign_view]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_assign_view](
	[viewassign_id] [int] IDENTITY(1,1) NOT NULL,
	[group_name] [int] NOT NULL,
	[view_type] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[viewassign_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_assigneddetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_assigneddetail](
	[assignedid] [int] IDENTITY(1,1) NOT NULL,
	[assignedDate] [datetime] NOT NULL,
	[assignedtoid] [int] NULL,
	[assignedbyid] [int] NULL,
	[requestid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[assignedid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_authorisedetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_authorisedetail](
	[authorisedid] [int] IDENTITY(1,1) NOT NULL,
	[authoriseddate] [datetime] NOT NULL,
	[authoriserid] [int] NULL,
	[requestid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[authorisedid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_authoriserdetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_authoriserdetail](
	[authoriserid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[authoriserid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_calendar]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_calendar](
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
/****** Object:  Table [dbo].[tbl_calendar_holidays]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_calendar_holidays](
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
/****** Object:  Table [dbo].[tbl_categorys_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_categorys_master](
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
/****** Object:  Table [dbo].[tbl_completeddetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_completeddetail](
	[completedid] [int] IDENTITY(1,1) NOT NULL,
	[completeddate] [datetime] NOT NULL,
	[completedbyid] [int] NULL,
	[requestid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[completedid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_conversation]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_conversation](
	[conversationid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[requestid] [int] NOT NULL,
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
/****** Object:  Table [dbo].[tbl_date_types_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_date_types_master](
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
/****** Object:  Table [dbo].[tbl_delivery_days_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_delivery_days_master](
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
/****** Object:  Table [dbo].[tbl_designation_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_designation_master](
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
/****** Object:  Table [dbo].[tbl_emaildetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_emaildetail](
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
/****** Object:  Table [dbo].[tbl_errorlog]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_errorlog](
	[error_id] [int] IDENTITY(1,1) NOT NULL,
	[datetime] [datetime] NOT NULL,
	[occurancedate] [date] NOT NULL,
	[activityid] [int] NOT NULL,
	[reportedbyid] [int] NULL,
	[reportedtoid] [int] NOT NULL,
	[errortypeid] [int] NOT NULL,
	[description] [varchar](max) NOT NULL,
	[document] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[error_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_errortype_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_errortype_master](
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
/****** Object:  Table [dbo].[tbl_estimationdetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_estimationdetail](
	[estimationid] [int] IDENTITY(1,1) NOT NULL,
	[estimationdate] [datetime] NOT NULL,
	[estimatedbyid] [int] NULL,
	[estimateddays] [int] NULL,
	[requestid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[estimationid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_feedback]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_feedback](
	[feedback_id] [int] IDENTITY(1,1) NOT NULL,
	[feedback_date] [datetime] NOT NULL,
	[feedback_question] [int] NOT NULL,
	[feedback_text] [varchar](255) NULL,
	[activityid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[feedback_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_feedback_question_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_feedback_question_master](
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
/****** Object:  Table [dbo].[tbl_frequency]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_frequency](
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
/****** Object:  Table [dbo].[tbl_gallery]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_gallery](
	[imgid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[uploadedbyid] [int] NULL,
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
/****** Object:  Table [dbo].[tbl_governance]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_governance](
	[governancedatetime] [datetime] NOT NULL,
	[governanceid] [int] IDENTITY(1,1) NOT NULL,
	[teamid] [int] NOT NULL,
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
/****** Object:  Table [dbo].[tbl_internaltask]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_internaltask](
	[internaltaskid] [int] IDENTITY(1,1) NOT NULL,
	[internaltaskdatetime] [datetime] NOT NULL,
	[internaltaskQuestion] [varchar](255) NOT NULL,
	[statusid] [int] NULL,
	[ownerid] [int] NULL,
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
/****** Object:  Table [dbo].[tbl_internaltaskchoice]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_internaltaskchoice](
	[internaltaskchoiceid] [int] IDENTITY(1,1) NOT NULL,
	[internaltaskchoicedatetime] [datetime] NOT NULL,
	[internaltaskchoice] [varchar](255) NOT NULL,
	[internaltaskid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[internaltaskchoiceid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_internaltaskstatus]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_internaltaskstatus](
	[internaltaskstatusid] [int] IDENTITY(1,1) NOT NULL,
	[internaltaskstatusdatetime] [datetime] NOT NULL,
	[memberid] [int] NULL,
	[internaltaskid] [int] NULL,
	[internaltaskchoiceid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[internaltaskstatusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_Issue_Action]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_Issue_Action](
	[Issue_Action_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[Issue] [varchar](255) NULL,
	[Action_taken] [varchar](255) NULL,
	[targetdate] [date] NULL,
	[updatedbyid] [int] NULL,
	[statusid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Issue_Action_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_leave_record]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_leave_type_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_leave_type_master](
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
/****** Object:  Table [dbo].[tbl_member]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_member](
	[memberid] [int] IDENTITY(1,1) NOT NULL,
	[userid] [int] NOT NULL,
	[teamid] [int] NOT NULL,
	[designationid] [int] NULL,
	[employeeid] [int] NULL,
	[DateofJoining] [date] NULL,
	[DateofBirth] [date] NULL,
	[Address] [varchar](max) NULL,
	[PhoneNumber] [varchar](10) NULL,
	[Avatar] [varchar](255) NULL,
	[aboutme] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[memberid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_navbar_footer_master]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_navbar_header_master]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_navbar_master]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_navbar_view]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_open_close]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_open_close](
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
/****** Object:  Table [dbo].[tbl_ot_detail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_ot_detail](
	[ot_id] [int] IDENTITY(1,1) NOT NULL,
	[timetrackerid] [int] NOT NULL,
	[ot_startdatetime] [datetime] NULL,
	[ot_enddatetime] [datetime] NULL,
	[ot_time] [int] NULL,
	[statusid] [int] NOT NULL,
	[otdocument] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[ot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_ot_status_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_ot_status_master](
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
/****** Object:  Table [dbo].[tbl_overviewdetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_overviewdetail](
	[overviewid] [int] IDENTITY(1,1) NOT NULL,
	[overviewdate] [datetime] NOT NULL,
	[providedbyid] [int] NOT NULL,
	[giventoid] [int] NULL,
	[sopcreatedid] [int] NULL,
	[requestid] [int] NOT NULL,
	[document] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[overviewid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_priority_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_priority_master](
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
/****** Object:  Table [dbo].[tbl_public_holidays_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_public_holidays_master](
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
/****** Object:  Table [dbo].[tbl_raw_activity_detail]    Script Date: 11/24/2018 1:25:23 PM ******/
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
	[raw_statusid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[raw_activity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_raw_score]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_raw_score](
	[raw_score_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[raw_teamid] [int] NULL,
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
/****** Object:  Table [dbo].[tbl_raw_team_master]    Script Date: 11/24/2018 1:25:23 PM ******/
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
	[raw_managementid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[raw_team_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_raw_team_member_master]    Script Date: 11/24/2018 1:25:23 PM ******/
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
/****** Object:  Table [dbo].[tbl_reply]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_reply](
	[replydatetime] [datetime] NOT NULL,
	[replyid] [int] IDENTITY(1,1) NOT NULL,
	[memberid] [int] NULL,
	[reply] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[replyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_requestdetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_requestdetail](
	[requestid] [int] IDENTITY(1,1) NOT NULL,
	[requestraiseddate] [datetime] NOT NULL,
	[requesttypeid] [int] NOT NULL,
	[priorityid] [int] NOT NULL,
	[userid] [int] NOT NULL,
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
/****** Object:  Table [dbo].[tbl_requeststatusdetail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_requeststatusdetail](
	[requeststatusid] [int] IDENTITY(1,1) NOT NULL,
	[requeststatusdate] [datetime] NOT NULL,
	[userid] [int] NOT NULL,
	[statusid] [int] NULL,
	[requestid] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[requeststatusid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_requesttype_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_requesttype_master](
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
/****** Object:  Table [dbo].[tbl_shift_update]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_shift_update](
	[updateid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[updateinbrief] [varchar](max) NULL,
	[recordedbyid] [int] NULL,
	[statusid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[updateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_status_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_status_master](
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
/****** Object:  Table [dbo].[tbl_subcategory_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_subcategory_master](
	[requestsubcategoryid] [int] IDENTITY(1,1) NOT NULL,
	[requestsubcategorydatetime] [datetime] NOT NULL,
	[categorysid] [int] NULL,
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
/****** Object:  Table [dbo].[tbl_success_stories]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_success_stories](
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
/****** Object:  Table [dbo].[tbl_suggestion]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_suggestion](
	[suggestiondatetime] [datetime] NOT NULL,
	[suggestionid] [int] IDENTITY(1,1) NOT NULL,
	[suggestion] [varchar](max) NOT NULL,
	[subject] [varchar](100) NULL,
	[suggestedbyid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[suggestionid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_team_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_team_master](
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
/****** Object:  Table [dbo].[tbl_team_metrics]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_team_metrics](
	[metrics_id] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[teamid] [int] NULL,
	[requesttypeid] [int] NULL,
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
/****** Object:  Table [dbo].[tbl_time_tracker]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_time_tracker](
	[timetrackerid] [int] IDENTITY(1,1) NOT NULL,
	[registerdatetime] [datetime] NOT NULL,
	[trackingdatetime] [date] NOT NULL,
	[memberid] [int] NULL,
	[teamid] [int] NULL,
	[categorysid] [int] NULL,
	[subcategoryid] [int] NULL,
	[task] [varchar](100) NULL,
	[requestid] [int] NULL,
	[description_text] [varchar](255) NULL,
	[totaltime] [int] NULL,
	[comments] [varchar](255) NULL,
	[startdatetime] [datetime] NULL,
	[stopdatetime] [datetime] NULL,
	[activityid] [int] NULL,
	[otid] [int] NULL,
	[valid_invalid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[timetrackerid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_UAT_detail]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_UAT_detail](
	[uatid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[UAT_statusid] [int] NULL,
	[requestid] [int] NOT NULL,
	[testedbyid] [int] NULL,
	[updatedbyid] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[uatid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbl_UAT_status_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_UAT_status_master](
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
/****** Object:  Table [dbo].[tbl_useful_links]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_useful_links](
	[linkid] [int] IDENTITY(1,1) NOT NULL,
	[date_time] [datetime] NOT NULL,
	[teamid] [int] NULL,
	[memberid] [int] NULL,
	[link] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[linkid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tbl_valid_invalid_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_valid_invalid_master](
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
/****** Object:  Table [dbo].[tbl_view_type_master]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_view_type_master](
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
/****** Object:  Table [dbo].[tbL_whatwedo]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbL_whatwedo](
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
/****** Object:  Table [dbo].[tbl_yes_no]    Script Date: 11/24/2018 1:25:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbl_yes_no](
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
/****** Object:  Index [auth_group_permissions_group_id_b120cbf9]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_group_id_b120cbf9] ON [dbo].[auth_group_permissions]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_group_permissions_permission_id_84c5c92e]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_group_permissions_permission_id_84c5c92e] ON [dbo].[auth_group_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_permission_content_type_id_2f476e4b]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_permission_content_type_id_2f476e4b] ON [dbo].[auth_permission]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_groups_group_id_97559544]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_groups_group_id_97559544] ON [dbo].[auth_user_groups]
(
	[group_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_groups_user_id_6a12ed8b]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_groups_user_id_6a12ed8b] ON [dbo].[auth_user_groups]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_user_permissions_permission_id_1fbb5f2c]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_user_permissions_permission_id_1fbb5f2c] ON [dbo].[auth_user_user_permissions]
(
	[permission_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [auth_user_user_permissions_user_id_a95ead1b]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [auth_user_user_permissions_user_id_a95ead1b] ON [dbo].[auth_user_user_permissions]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_content_type_id_c4bce8eb]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [django_admin_log_content_type_id_c4bce8eb] ON [dbo].[django_admin_log]
(
	[content_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_admin_log_user_id_c564eba6]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [django_admin_log_user_id_c564eba6] ON [dbo].[django_admin_log]
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [django_session_expire_date_a5c62663]    Script Date: 11/24/2018 1:25:23 PM ******/
CREATE NONCLUSTERED INDEX [django_session_expire_date_a5c62663] ON [dbo].[django_session]
(
	[expire_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_acceptrejectdetail] ADD  DEFAULT (getdate()) FOR [estacceptrejectdate]
GO
ALTER TABLE [dbo].[tbl_activity] ADD  DEFAULT (getdate()) FOR [registereddate]
GO
ALTER TABLE [dbo].[tbl_activitystatus_calendar] ADD  DEFAULT (getdate()) FOR [activitystatusdate]
GO
ALTER TABLE [dbo].[tbl_appreciation] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_assigneddetail] ADD  DEFAULT (getdate()) FOR [assignedDate]
GO
ALTER TABLE [dbo].[tbl_authorisedetail] ADD  DEFAULT (getdate()) FOR [authoriseddate]
GO
ALTER TABLE [dbo].[tbl_categorys_master] ADD  DEFAULT (getdate()) FOR [requestcategorydatetime]
GO
ALTER TABLE [dbo].[tbl_completeddetail] ADD  DEFAULT (getdate()) FOR [completeddate]
GO
ALTER TABLE [dbo].[tbl_conversation] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_emaildetail] ADD  DEFAULT (getdate()) FOR [emaildate]
GO
ALTER TABLE [dbo].[tbl_errorlog] ADD  DEFAULT (getdate()) FOR [datetime]
GO
ALTER TABLE [dbo].[tbl_estimationdetail] ADD  DEFAULT (getdate()) FOR [estimationdate]
GO
ALTER TABLE [dbo].[tbl_feedback] ADD  DEFAULT (getdate()) FOR [feedback_date]
GO
ALTER TABLE [dbo].[tbl_feedback_question_master] ADD  DEFAULT (getdate()) FOR [feedback_questiondate]
GO
ALTER TABLE [dbo].[tbl_gallery] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_governance] ADD  DEFAULT (getdate()) FOR [governancedatetime]
GO
ALTER TABLE [dbo].[tbl_internaltask] ADD  DEFAULT (getdate()) FOR [internaltaskdatetime]
GO
ALTER TABLE [dbo].[tbl_internaltaskchoice] ADD  DEFAULT (getdate()) FOR [internaltaskchoicedatetime]
GO
ALTER TABLE [dbo].[tbl_internaltaskstatus] ADD  DEFAULT (getdate()) FOR [internaltaskstatusdatetime]
GO
ALTER TABLE [dbo].[tbl_Issue_Action] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_leave_record] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_leave_type_master] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_overviewdetail] ADD  DEFAULT (getdate()) FOR [overviewdate]
GO
ALTER TABLE [dbo].[tbl_raw_activity_detail] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_score] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_team_master] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_raw_team_member_master] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_reply] ADD  DEFAULT (getdate()) FOR [replydatetime]
GO
ALTER TABLE [dbo].[tbl_requestdetail] ADD  DEFAULT (getdate()) FOR [requestraiseddate]
GO
ALTER TABLE [dbo].[tbl_requeststatusdetail] ADD  DEFAULT (getdate()) FOR [requeststatusdate]
GO
ALTER TABLE [dbo].[tbl_shift_update] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_subcategory_master] ADD  DEFAULT (getdate()) FOR [requestsubcategorydatetime]
GO
ALTER TABLE [dbo].[tbl_success_stories] ADD  DEFAULT (getdate()) FOR [storiesdatetime]
GO
ALTER TABLE [dbo].[tbl_suggestion] ADD  DEFAULT (getdate()) FOR [suggestiondatetime]
GO
ALTER TABLE [dbo].[tbl_team_master] ADD  DEFAULT (getdate()) FOR [teamdatetime]
GO
ALTER TABLE [dbo].[tbl_team_metrics] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_time_tracker] ADD  DEFAULT (getdate()) FOR [registerdatetime]
GO
ALTER TABLE [dbo].[tbl_time_tracker] ADD  DEFAULT (getdate()) FOR [trackingdatetime]
GO
ALTER TABLE [dbo].[tbl_time_tracker] ADD  DEFAULT (getdate()) FOR [startdatetime]
GO
ALTER TABLE [dbo].[tbl_time_tracker] ADD  DEFAULT (getdate()) FOR [stopdatetime]
GO
ALTER TABLE [dbo].[tbl_UAT_detail] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_UAT_status_master] ADD  DEFAULT (getdate()) FOR [date_time]
GO
ALTER TABLE [dbo].[tbl_useful_links] ADD  DEFAULT (getdate()) FOR [date_time]
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
ALTER TABLE [dbo].[tbl_acceptrejectdetail]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_acceptrejectdetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([activitystatus])
REFERENCES [dbo].[tbl_open_close] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([date_types])
REFERENCES [dbo].[tbl_date_types_master] ([date_typesid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([frequency])
REFERENCES [dbo].[tbl_frequency] ([frequencyid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([primaryowner])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([requestcategorys])
REFERENCES [dbo].[tbl_categorys_master] ([requestcategoryid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([secondaryowner])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_activity]  WITH CHECK ADD FOREIGN KEY([teamname])
REFERENCES [dbo].[tbl_team_master] ([teamid])
GO
ALTER TABLE [dbo].[tbl_activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([activitystatus])
REFERENCES [dbo].[tbl_status_master] ([statusnameid])
GO
ALTER TABLE [dbo].[tbl_activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([activityid])
REFERENCES [dbo].[tbl_activity] ([activityid])
GO
ALTER TABLE [dbo].[tbl_activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([reallocatedtoid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_activitystatus_calendar]  WITH CHECK ADD FOREIGN KEY([recordenteredbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_appreciation]  WITH CHECK ADD FOREIGN KEY([Appreciated_to])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_appreciation]  WITH CHECK ADD FOREIGN KEY([appreciation_status])
REFERENCES [dbo].[tbl_open_close] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_assign_view]  WITH CHECK ADD FOREIGN KEY([group_name])
REFERENCES [dbo].[auth_group] ([id])
GO
ALTER TABLE [dbo].[tbl_assign_view]  WITH CHECK ADD FOREIGN KEY([view_type])
REFERENCES [dbo].[tbl_view_type_master] ([view_id])
GO
ALTER TABLE [dbo].[tbl_assigneddetail]  WITH CHECK ADD FOREIGN KEY([assignedtoid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_assigneddetail]  WITH CHECK ADD FOREIGN KEY([assignedbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_assigneddetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_authorisedetail]  WITH CHECK ADD FOREIGN KEY([authoriserid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_authorisedetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_authoriserdetail]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_completeddetail]  WITH CHECK ADD FOREIGN KEY([completedbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_completeddetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_conversation]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_conversation]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_emaildetail]  WITH CHECK ADD FOREIGN KEY([requestdetail])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_errorlog]  WITH CHECK ADD FOREIGN KEY([activityid])
REFERENCES [dbo].[tbl_activity] ([activityid])
GO
ALTER TABLE [dbo].[tbl_errorlog]  WITH CHECK ADD FOREIGN KEY([errortypeid])
REFERENCES [dbo].[tbl_errortype_master] ([error_typeid])
GO
ALTER TABLE [dbo].[tbl_errorlog]  WITH CHECK ADD FOREIGN KEY([errortypeid])
REFERENCES [dbo].[tbl_errortype_master] ([error_typeid])
GO
ALTER TABLE [dbo].[tbl_errorlog]  WITH CHECK ADD FOREIGN KEY([reportedbyid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_errorlog]  WITH CHECK ADD FOREIGN KEY([reportedtoid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_estimationdetail]  WITH CHECK ADD FOREIGN KEY([estimatedbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_estimationdetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_feedback]  WITH CHECK ADD FOREIGN KEY([activityid])
REFERENCES [dbo].[tbl_activity] ([activityid])
GO
ALTER TABLE [dbo].[tbl_feedback]  WITH CHECK ADD FOREIGN KEY([feedback_question])
REFERENCES [dbo].[tbl_feedback_question_master] ([feedback_questionid])
GO
ALTER TABLE [dbo].[tbl_gallery]  WITH CHECK ADD FOREIGN KEY([uploadedbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_governance]  WITH CHECK ADD FOREIGN KEY([teamid])
REFERENCES [dbo].[tbl_team_master] ([teamid])
GO
ALTER TABLE [dbo].[tbl_internaltask]  WITH CHECK ADD FOREIGN KEY([ownerid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_internaltask]  WITH CHECK ADD FOREIGN KEY([statusid])
REFERENCES [dbo].[tbl_open_close] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_internaltaskchoice]  WITH CHECK ADD FOREIGN KEY([internaltaskid])
REFERENCES [dbo].[tbl_internaltask] ([internaltaskid])
GO
ALTER TABLE [dbo].[tbl_internaltaskstatus]  WITH CHECK ADD FOREIGN KEY([internaltaskid])
REFERENCES [dbo].[tbl_internaltask] ([internaltaskid])
GO
ALTER TABLE [dbo].[tbl_internaltaskstatus]  WITH CHECK ADD FOREIGN KEY([internaltaskchoiceid])
REFERENCES [dbo].[tbl_internaltaskchoice] ([internaltaskchoiceid])
GO
ALTER TABLE [dbo].[tbl_internaltaskstatus]  WITH CHECK ADD FOREIGN KEY([memberid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_Issue_Action]  WITH CHECK ADD FOREIGN KEY([statusid])
REFERENCES [dbo].[tbl_open_close] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_Issue_Action]  WITH CHECK ADD FOREIGN KEY([updatedbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_leave_record]  WITH CHECK ADD FOREIGN KEY([leave_type])
REFERENCES [dbo].[tbl_leave_type_master] ([leavetypeid])
GO
ALTER TABLE [dbo].[tbl_leave_record]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_member]  WITH CHECK ADD FOREIGN KEY([designationid])
REFERENCES [dbo].[tbl_designation_master] ([designationid])
GO
ALTER TABLE [dbo].[tbl_member]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_member]  WITH CHECK ADD FOREIGN KEY([teamid])
REFERENCES [dbo].[tbl_team_master] ([teamid])
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
REFERENCES [dbo].[tbl_view_type_master] ([view_id])
GO
ALTER TABLE [dbo].[tbl_ot_detail]  WITH CHECK ADD FOREIGN KEY([statusid])
REFERENCES [dbo].[tbl_ot_status_master] ([ot_statusid])
GO
ALTER TABLE [dbo].[tbl_ot_detail]  WITH CHECK ADD FOREIGN KEY([timetrackerid])
REFERENCES [dbo].[tbl_time_tracker] ([timetrackerid])
GO
ALTER TABLE [dbo].[tbl_overviewdetail]  WITH CHECK ADD FOREIGN KEY([giventoid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_overviewdetail]  WITH CHECK ADD FOREIGN KEY([providedbyid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_overviewdetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_overviewdetail]  WITH CHECK ADD FOREIGN KEY([sopcreatedid])
REFERENCES [dbo].[tbl_yes_no] ([optionsid])
GO
ALTER TABLE [dbo].[tbl_raw_activity_detail]  WITH CHECK ADD FOREIGN KEY([raw_statusid])
REFERENCES [dbo].[tbl_open_close] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_raw_score]  WITH CHECK ADD FOREIGN KEY([raw_teamid])
REFERENCES [dbo].[tbl_raw_team_master] ([raw_team_id])
GO
ALTER TABLE [dbo].[tbl_raw_team_master]  WITH CHECK ADD FOREIGN KEY([raw_managementid])
REFERENCES [dbo].[tbl_yes_no] ([optionsid])
GO
ALTER TABLE [dbo].[tbl_raw_team_master]  WITH CHECK ADD FOREIGN KEY([valid_invalid])
REFERENCES [dbo].[tbl_valid_invalid_master] ([valid_invaidid])
GO
ALTER TABLE [dbo].[tbl_raw_team_member_master]  WITH CHECK ADD FOREIGN KEY([raw_member])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_raw_team_member_master]  WITH CHECK ADD FOREIGN KEY([raw_team])
REFERENCES [dbo].[tbl_raw_team_master] ([raw_team_id])
GO
ALTER TABLE [dbo].[tbl_reply]  WITH CHECK ADD FOREIGN KEY([memberid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_requestdetail]  WITH CHECK ADD FOREIGN KEY([priorityid])
REFERENCES [dbo].[tbl_priority_master] ([requestpriorityid])
GO
ALTER TABLE [dbo].[tbl_requestdetail]  WITH CHECK ADD FOREIGN KEY([requesttypeid])
REFERENCES [dbo].[tbl_requesttype_master] ([requesttypeid])
GO
ALTER TABLE [dbo].[tbl_requestdetail]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_requeststatusdetail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_requeststatusdetail]  WITH CHECK ADD FOREIGN KEY([statusid])
REFERENCES [dbo].[tbl_status_master] ([statusnameid])
GO
ALTER TABLE [dbo].[tbl_requeststatusdetail]  WITH CHECK ADD FOREIGN KEY([userid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_shift_update]  WITH CHECK ADD FOREIGN KEY([recordedbyid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_shift_update]  WITH CHECK ADD FOREIGN KEY([statusid])
REFERENCES [dbo].[tbl_open_close] ([activitystatusid])
GO
ALTER TABLE [dbo].[tbl_subcategory_master]  WITH CHECK ADD FOREIGN KEY([categorysid])
REFERENCES [dbo].[tbl_categorys_master] ([requestcategoryid])
GO
ALTER TABLE [dbo].[tbl_suggestion]  WITH CHECK ADD FOREIGN KEY([suggestedbyid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_team_metrics]  WITH CHECK ADD FOREIGN KEY([requesttypeid])
REFERENCES [dbo].[tbl_requesttype_master] ([requesttypeid])
GO
ALTER TABLE [dbo].[tbl_team_metrics]  WITH CHECK ADD FOREIGN KEY([teamid])
REFERENCES [dbo].[tbl_team_master] ([teamid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([memberid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([activityid])
REFERENCES [dbo].[tbl_activity] ([activityid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([categorysid])
REFERENCES [dbo].[tbl_categorys_master] ([requestcategoryid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([subcategoryid])
REFERENCES [dbo].[tbl_subcategory_master] ([requestsubcategoryid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([teamid])
REFERENCES [dbo].[tbl_team_master] ([teamid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([valid_invalid])
REFERENCES [dbo].[tbl_valid_invalid_master] ([valid_invaidid])
GO
ALTER TABLE [dbo].[tbl_time_tracker]  WITH CHECK ADD FOREIGN KEY([otid])
REFERENCES [dbo].[tbl_ot_detail] ([ot_id])
GO
ALTER TABLE [dbo].[tbl_UAT_detail]  WITH CHECK ADD FOREIGN KEY([requestid])
REFERENCES [dbo].[tbl_requestdetail] ([requestid])
GO
ALTER TABLE [dbo].[tbl_UAT_detail]  WITH CHECK ADD FOREIGN KEY([testedbyid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_UAT_detail]  WITH CHECK ADD FOREIGN KEY([UAT_statusid])
REFERENCES [dbo].[tbl_UAT_status_master] ([UAT_status_id])
GO
ALTER TABLE [dbo].[tbl_UAT_detail]  WITH CHECK ADD FOREIGN KEY([updatedbyid])
REFERENCES [dbo].[auth_user] ([id])
GO
ALTER TABLE [dbo].[tbl_useful_links]  WITH CHECK ADD FOREIGN KEY([memberid])
REFERENCES [dbo].[tbl_member] ([memberid])
GO
ALTER TABLE [dbo].[tbl_useful_links]  WITH CHECK ADD FOREIGN KEY([teamid])
REFERENCES [dbo].[tbl_team_master] ([teamid])
GO
ALTER TABLE [dbo].[django_admin_log]  WITH CHECK ADD  CONSTRAINT [django_admin_log_action_flag_a8637d59_check] CHECK  (([action_flag]>=(0)))
GO
ALTER TABLE [dbo].[django_admin_log] CHECK CONSTRAINT [django_admin_log_action_flag_a8637d59_check]
GO
USE [master]
GO
ALTER DATABASE [SDPM_team] SET  READ_WRITE 
GO
