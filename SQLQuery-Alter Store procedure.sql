USE [CentralMI]
GO
/****** Object:  StoredProcedure [dbo].[uspjoin]    Script Date: 12/31/2017 8:55:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[uspjoin]  
@status varchar(50),
@stage varchar(50)
As
SELECT r.RequestId, 
	   sd.StatusName as RequestStatus,
	   rsd.RequestStatusChangeBy,
	   r.RequestRaisedDate, 
	   r.RequestOwner, 
	   p.RequestPriorityName, 
	   r.DateforCompletion, 
	   r.RequestDescription, 
	   a.AuthorisedDate, 
	   a.Authorisedby, 
	   o.OptionsName,
	   rad.RequestAssignedDate, 
	   rad.RequestAssignedBy, 
	   rad.RequestAssignedTo,
	   ov.OverViewDate, 
	   ov.Providedby, 
	   ov.Givento, 
	   ov.SOPCreatedOptionsId,
	   ed.EstimationDate, 
	   ed.EstimatedBy,
	   etd.EstimationTypeName,  
	   mirb.[MiMemberName] as AssignedBy,
	   mirt.[MiMemberName] as AssignedTo,
	   migt.[MiMemberName] as GivenTo,
	   osop.[OptionsName] as SOPoption,
	   ard.[EstAcceptRejectDate],
	   ard.[EstAcceptRejectOption],
	   ard.[EstAcceptRejectIntId],
	   ard.[EstAcceptRejectBy],
	   ajo.[AcceptRejectOptionName],
	   cd.[CompletedDate],
	   cd.[CompletedBy],
	   cd.[CompletedIntId],
	   --case when @status = 'All' then 'All' else sd.StatusName end as NewStatus,
	   Case 
			When  cd.[CompletedDate] is not null Then 'CompletedStage'
			When  EstimationDate is not null and ajo.[AcceptRejectOptionName] in ('Rejected') Then 'RejectionStage'
			When  EstimationDate is not null and ajo.[AcceptRejectOptionName] in ('Accepted') Then 'WIPStage' 
			When  EstimationDate is not null Then 'EstimateStage' 
			When  OverViewDate is not null Then 'OverviewStage'
			When  RequestAssignedDate is not null then 'AssignedStage'
			When  AuthorisedDate is not null then 'AuthorisedStage'
			When  RequestRaisedDate is not null then 'RequestStage'
	   End As Stage
	   FROM [requestdetail]  as r
  
  left Join [authorisedetail]  as a on  r.[RequestId] = a.[RequestId] 
  left join Options as o on a.AuthorisedOptionsId = o.OptionsId
  left join [Requeststatusdetail] as rsd on r.[RequestId] = rsd.[requestid]
  left join [statusdetail] as sd on rsd.[RequestStatus] = sd.[StatusNameId]
  left join [requesttypedetail] as rtd on r.[RequestTypeId] = rtd.[RequestTypeId]
  left join [RequestPrioritydetail] as p on r.RequestPriorityId = p.RequestPriorityId
  left join [overviewdetail] as ov on r.[RequestId] = ov.[RequestId]
  left join [estimationdetail] as ed on r.[RequestId] = ed.[RequestId]
  left join [estimationtypedetail] as etd on ed.[EstimationTypeId] = etd.[EstimationTypeId]
  left join [Requestassigneddetail] as rad  on r.[RequestId] = rad.[Requestid]
  left Join [mimember] as mirb on rad.RequestAssignedBy = mirb.[MiMemberId]
  left Join [mimember] as mirt on rad.RequestAssignedTo = mirt.[MiMemberId]
  left Join [mimember] as migt on ov.Givento = migt.[MiMemberId]
  left Join [Options] as osop on ov.SOPCreatedOptionsId = osop.[OptionsId]
  left Join [AcceptRejectdetail] as ard on r.[RequestId] = ard.[Requestid]
  left Join [AcceptRejectOption] as ajo on ard.[EstAcceptRejectOption] = ajo.[AcceptRejectOptionId]
  left Join [completeddetail] as cd on r.[RequestId] = cd.[Requestid]
  where  
  (case when @status = 'All' then 'All' else sd.StatusName end )  = @status
  and 
  (Case 
	   when @stage = 'All' then 'All' Else 
		(Case 
			When  cd.[CompletedDate] is not null Then 'CompletedStage'
			When  EstimationDate is not null and ajo.[AcceptRejectOptionName] in ('Rejected') Then 'RejectionStage'
			When  EstimationDate is not null and ajo.[AcceptRejectOptionName] in ('Accepted') Then 'WIPStage' 
			When  EstimationDate is not null Then 'EstimateStage' 
			When  OverViewDate is not null Then 'OverviewStage'
			When  RequestAssignedDate is not null then 'AssignedStage'
			When  AuthorisedDate is not null then 'AuthorisedStage'
			When  RequestRaisedDate is not null then 'RequestStage'
	   End
) 
		End) = @stage
	   
   
 execute [dbo].[uspjoin] 'All', 'All'  


 select  * from completeddetail 
 CompletedDate
 CompletedBy
 CompletedIntId

 
