/****** Script for SelectTopNRows command from SSMS  ******/
create table activitystatus_calendar(
activitystatuscalendarid  int not null primary key Identity(1,1),
activitystatusdate datetime default getdate() not null,
activitystatus int foreign key references statusdetail(statusnameid),
activityid int foreign key references activity(activityid),
activitycalendardate date,
reallocatedto int foreign key references mimember(mimemberId),
recordenteredby int foreign key references mimember(mimemberId)

)

select *  from activitystatus_calendar