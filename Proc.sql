create proc SumALL
	@n int, @res int output
as
begin
	declare @i int
	set @res =1 
	set @i = 1
	while (@i<=@n)
	begin
		set @res = @res*@i
		set @i = @i+1
	end
end
go
create proc Factorial_Sum
	@n int
as
begin
	declare @i int
	declare @sum int
	set @i = 1
	set @sum = 0
	while (@i<=@n)
	begin
		declare @k int
		exec SumALL @i, @k output
		set @sum = @sum + @k
		set @i = @i+1
	end
	print cast(@sum as nvarchar(MAX)) + N' is result'
end
go
exec Factorial_Sum 5
go
use QLHV2222
go
create proc stu_passed
	@name nvarchar(50)
as
begin 
	select s.*
			from student s, result r, subject su
			where s.ID=r.studentID and
			r.subjectID=su.ID and
			su.name=@name and r.mark>=5 and
			r.times > = all ( select r1.times
			from result r1 where r1.studentID=s.ID and
			r1.subjectID=su.ID
			)
end
go	
exec stu_passed N'Cơ sở dữ liệu'
go
create proc avg_grade 
@StudentName nvarchar(50), @res float output
as
begin
	select @res = SUM(r.Mark * su.credits) / SUM(su.credits)
	from Student s, Subject su, Result r
	where s.ID = r.StudentID and su.ID = r.SubjectID
	and s.Name = @StudentName and r.Times >= all
	(select r1.Times from Result r1 where r1.StudentID = s.ID and su.ID = r1.SubjectID)
	print @res
end
declare @mark float
exec avg_grade N'Nguyễn Thị Kiề Trang', @mark output
go
create proc StudentList
@ClassID varchar(50)
as
begin
	declare @start int
	declare @end int 
	select @start = year(BeginYear), @end = year(EndYear)
	from Class where @ClassID = ID
	print N'Class ID: ' + @ClassID + 'BeginYear: ' + cast (@start as varchar(20)) + 'EndYear: ' + cast(@end as varchar(20))
	declare c cursor for ( select Name, ID, Birthday from Student where ClassID = @ClassID)
	open c
	declare @ID varchar(50)
	declare @birthday datetime
	declare @name nvarchar(50)
	fetch next from c into @name, @ID, @birthday
	declare @i int
	set @i=1
	while (@@FETCH_STATUS=0)
	begin
		print cast(@i as varchar(5)) + '. Student Name: ' + @name
		+ ' Student ID: ' + @ID + ' Birthday: ' + cast(@birthday as varchar(40))
		fetch next from c into @name, @ID, @birthday
		set @i = @i+1
	end
	set @i = @i-1
	print 'Total: ' + cast(@i as varchar(5)) + ' Students'
	close c
	deallocate c
end
go
exec StudentList 'LH000001 '
go
create proc SubjectList
@StudentID varchar(50)
as
begin
	declare d cursor for
	(select sub.Name, sub.Credits, r.Mark from Subject sub, result r
	where sub.ID = r.SubjectID and r.StudentID = @StudentID 
	and r.mark>=5
	and r.times >= all ( select r1.times from
	result r1 where r1.subjectID=r.subjectID and
	r1.studentID=r.studentID))
	open d 
	declare @name nvarchar(50)
	declare @credits int
	declare @mark float
	declare @i int 
	set @i =1 
	fetch next from d into @name, @credits, @mark
	while (@@FETCH_STATUS =0)
	begin
		print cast(@i as varchar(5)) + '. SubjectName: ' + @name + 'Credits: ' +cast(@credits as varchar(5)) + ' Mark: ' + cast(@mark as varchar(5))
		fetch next from d into @name, @credits, @mark
		set @i =@i +1
	end
	close d
	deallocate d
end
go
exec SubjectList 'HV000001 '
go
create proc ClassList
@ClassID varchar(20)
as
begin
	declare @start int
	declare @end int 
	select @start = year(BeginYear), @end = year(EndYear)
	from Class where @ClassID = ID
	print 'Class ID: ' + @ClassID + ' BeginYear: ' + cast (@start as varchar(20)) + ' EndYear: ' + cast(@end as varchar(20))
	declare @i int
	set @i =1
	declare @name nvarchar(50)
	declare @id varchar(10)
	declare @birthday datetime
	declare @subname nvarchar(50)
	declare @mark int
	declare d cursor for (select s.name, s.ID, s.Birthday, sub.Name, r.Mark
	from student s, Subject sub, Result r
	where r.SubjectID = sub.ID and r.StudentID = s.ID and s.ClassID = @ClassID and
	r.mark>=5
	and r.times >= all ( select r1.times from
	result r1 where r1.subjectID=r.subjectID and
	r1.
	studentID=r.studentID))
	open d 
	fetch next from d into @name, @id, @birthday, @subname, @mark
	while (@@FETCH_STATUS = 0 )
	begin
		print cast(@i as varchar(10)) + '. Name:'+ @name +' ID:' + @ID +' Birthday:'+cast(@birthday as varchar(50))
		print '-Passed Subjects:'
		print' Sub Name:' + @subname +' Mark:'+cast(@mark as varchar(4))
		fetch next from d into @name, @id, @birthday, @subname, @mark
		set @i =@i+1
	end
	set @i=@i-1
	print 'Total:' + cast(@i as varchar(20))
	close d
	deallocate d
end 
go
exec ClassList 'LH000001 '
go
create proc getAVG
@StudentID varchar(20), @mark float output
as
begin
	select @mark = SUM(sub.Credits*r.Mark)/SUM(sub.Credits)
	from Subject sub, Result r
	where r.mark is not null and r.SubjectID = sub.ID and r.StudentID = @StudentID and
	r.Times > = all (select r1.times from result r1 
 where r1.studentID=@StudentID and
r1.subjectID=sub.ID
)
end
go
create proc ABC
@classID varchar(20)
as 
begin
	declare @managerID varchar(20)
	declare @managerName nvarchar(50)
	select @managerID = c.ManagerID, @managerName = t.Name
	from Class c, Teacher t
	where c.ManagerID = t.ID and c.ID = @classID
	print 'ClassID: ' + @classID+' ManagerID: 
	'+
	@managerID + ' ManagerName: '+
	@managerName
	declare c cursor for (select s.ID, s.name from student s where
s.classID=@classID)
	declare @id varchar(20)
	declare @name nvarchar(50)
	open c
	fetch next from c into @id, @name 
	declare @i int 
	set @i = 1
	while (@@FETCH_STATUS = 0)
	begin
		declare @avg float
		exec getAVG @id, @avg output
		print cast(@i as varchar(4))+'.' + @ID 
		+ ' 
		' +@name + ' ' +cast (@avg as
		varchar(20))
		set @i=@i+1
		fetch next from c into @id,@name
	end
	close c
	deallocate c
end
exec ABC 'LH000001 '
select * from Student
go
alter table Teacher add evaluation nvarchar(50)
go
create proc Step_1
@TeacherID varchar(20), @kq int output
as
begin
	if exists(select 1 from Teacher where @TeacherID = ID)
		set @kq = 1
	else 
		set @kq = 0
end
go
create proc FillTeacher
@TeacherID varchar(20), @evaluation nvarchar(50) output
as
begin
	declare @k int
	exec Step_1 @TeacherID, @k output
	if @k = 0
	begin
		print N'Không tồn tại ID'
		return
	end
	else
	begin
		declare @i int
		select @i = COUNT(*) from Ability where @TeacherID = TeacherID
		if @i < 5
			set @evaluation = N'Không đạt'
		else
			if exists(select 1 from Class where @TeacherID = ManagerID)
				set @evaluation = N'Giỏi'
			else 
				set @evaluation = N'Khá'
	end
	update Teacher set evaluation = @evaluation where @TeacherID =ID
	print @evaluation
end
go
create proc FillAllTeacher
as
begin
	declare c cursor for select ID from Teacher
	open c
	declare @id varchar(20)
	fetch next from c into @id
	while(@@FETCH_STATUS = 0)
	begin
		declare @kq nvarchar(20)
		exec FillTeacher @id, @kq output
		fetch next from c into @id
	end
	close c
	deallocate c
end
go
alter table Subject add evaluation nvarchar(50)
go
create proc Ex3
@SubjectID varchar(20)
as
begin
	declare @stu_passed int
	declare @total_stu int
	select @stu_passed = COUNT(*) from Result r 
	where r.SubjectID = @SubjectID and
	r.Mark >=5 and 
	r.Times >= all(select r1.times from Result r1
					where r1.StudentID = r.StudentID and r1.SubjectID = @SubjectID)
	select @total_stu = COUNT(distinct r.StudentID)
	from Result r where r.SubjectID = @SubjectID
	declare @evaluation nvarchar(50)
	print cast(@stu_passed as varchar(20)) + ' ' + cast(@total_stu as varchar(20))
	if( @stu_passed > @total_stu / 2.0)
		set @evaluation = N'Đạt'
	else 
		set @evaluation = N'Không đạt'
	update Subject set evaluation = @evaluation where ID = @SubjectID
	print @evaluation
end
go
exec Ex3 'MH00001 '
go
create proc getMark
@studentID varchar(50),@kq float output
as begin
	select @kq = sum(r.Mark*sub.Credits)*1.0/sum(sub.Credits)
	from Result r, Subject sub
	where r.StudentID = @studentID and sub.ID = r.SubjectID
	and r.Mark is not null and r.Times >= all(select r1.times 
				from Result r1 where r1.SubjectID = r.SubjectID 
				and r1.StudentID = @studentID)
end
go
create proc XuatMonHoc
@studentID varchar(50)
as begin
	declare @i int
	set @i = 1
	declare @subname nvarchar(50)
	declare @credits int
	declare @mark int
	declare d cursor for (Select sub.name, sub.Credits, r.Mark from Result r, Subject sub 
				where r.StudentID = @studentID and r.SubjectID = sub.ID and r.Mark is not null
				and r.times >= all (select r1.times from Result r1 where r1.SubjectID = r.SubjectID
									and r1.StudentID = @studentID))
	open d
	fetch next from d into @subname, @credits, @mark
	while(@@FETCH_STATUS = 0)
	begin 
		print cast(@i as varchar(50)) + ' ' + @subname + ' ' + cast(@credits as varchar(10)) + ' ' + cast(@mark as varchar(10))
		set @i = @i+1
		fetch next from d into @subname, @credits, @mark
	end
	close d
	deallocate d
end
go
create proc XuatBangDiem
@studentID varchar(20)
as begin
	declare @name nvarchar(50)
	select @name = name from Student where @studentID = ID
	declare @gpa float
	exec getMark @studentID, @gpa output
	print 'ho ten:' +@name
	print 'DTB:' + cast(ROUND(@gpa,2) as varchar(4))
	if(@gpa>=8)
		print 'Xep loai: Gioi'
	else
		if(@gpa>=7)
			print 'Xep loai: Khá'
		else
			print 'Xep loai: Trung Bình'
	print 'Ket qua hoc tap'
	exec XuatMonHoc @studentID
end
go
exec XuatBangDiem 'HV000001 '
go
select * from Student s, Result r, Subject sub
where s.ID ='HV000001 ' and r.SubjectID = sub.ID and s.ID = r.StudentID
