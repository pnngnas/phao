use QLHV2222;

go
--Cau 1
select s.ID, s.Name 
from Subject s
join Result r on r.SubjectID = s.ID
where s.Credits = 4
and
r.Times > 1
group by s.ID, s.Name
having COUNT(distinct r.StudentID) = (select COUNT(*) from Student)
go


--Cau 2

create proc cau2
@subjectID varchar(20), @evaluation nvarchar(10) output as
begin
	declare @a int = (
		select count(distinct StudentID) from Result where SubjectID = @subjectID
	)
	declare @b int = (
		select COUNT(distinct r.StudentID) from Result r
		where r.Mark >= 5
		and
		r.Times >= all(
			select Times from Result where SubjectID = r.SubjectID and StudentID = r.StudentID
		)
		and r.SubjectID = @subjectID
	)

	if (@b > @a*1.0/2)
		set @evaluation = N'Đạt'
	else
		set @evaluation = N'Không đạt'
end

go


-- Câu 3

alter table Subject
add danhgia nvarchar(30);

go
create proc cau3
@classID varchar(20) as
begin
	declare c cursor for (
		select distinct SubjectID
		from Course
		where ClassID = @classID
	)
	open c;
	declare @subjectID varchar(20);
	declare @output nvarchar(30);
	fetch next from c into @subjectID
	while @@FETCH_STATUS = 0
	begin
		exec cau2 @subjectID, @output output;
		update Subject set danhgia = @output where ID = @subjectID;
		fetch next from c into @subjectID	
	end
	close c;
	deallocate c;
end
