
select * from Ability;
go
drop proc update_number_of_Course
go
create proc update_number_of_Course as
begin
	declare c cursor for (
		select TeacherID, SubjectID, COUNT(*) as nums from Course
		group by TeacherID, SubjectID
	)
	open c;
	declare @teacherId varchar(10);
	declare @subjectId varchar(10);
	declare @count int;
	fetch next from c into @teacherId, @subjectId, @count;
	while @@FETCH_STATUS = 0
		begin
			update Ability set NumofCours = @count
			where @teacherId = TeacherID and @subjectId = SubjectID;
			fetch next from c into @teacherId, @subjectId, @count;
		end;
	close c;
	deallocate c;
end;
go
drop proc listSubject;
go
create proc listSubject
@studentId varchar(10) as
begin
	declare @name nvarchar(100);
	declare @id varchar(20);
	declare @birthday varchar(20);
	select @name = Name, @id = ID, @birthday = cast(Birthday as varchar(100))
	from Student where ID = @studentId
	print 'Student Name: ' + @name + ' StudentID: ' + @id + ' Birthday: ' + @birthday + char(10)
	print '   -Passed Subjects:' + char(10)
	declare c cursor for (
		select s.Name, cast(r.Mark as varchar(2)) from Result as r
		join Subject as s on s.ID = r.SubjectID
		where r.StudentID = @studentId
		and
		r.Mark >= 5
		and
		r.Times >= all(select Times from Result where r.SubjectID = SubjectID and r.StudentID = StudentID)
	)
	open c;
	declare @subjectName nvarchar(100);
	declare @mark varchar(2);
	fetch next from c into @subjectName, @mark;
	while @@FETCH_STATUS = 0
		begin
			print '      SubjectName: ' + @subjectName + '  Mark: ' + @mark + char(10);
			fetch next from c into @subjectName, @mark;
		end;
	close c;
	deallocate c;
end;
go

exec listSubject 'HV000001';