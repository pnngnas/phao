use QLHV2222
go
--câu 1
select s.ID, s.Name
from Student s, Result r, Subject sub
where s.ID = r.StudentID and r.SubjectID = sub.ID and s.ClassID = 'LH0001'
and r.Mark > 5 and r.times = 1
group by s.ID, s.Name
having COUNT(distinct s.ID) >= all(select count(distinct r1.StudentID) from Result r1 join Student s1 
						on r1.StudentID = s1.ID where r1.StudentID = s.ID and s1.ClassID = 'LH0001')
go
--câu 2
create proc Cau2
@tearcherID varchar(50),@kq nvarchar(50) output
as begin
	declare @x varchar(40)
	select @x = c.ID from Class c where c.ManagerID = @tearcherID
	declare @b int
	select @b = count(distinct r.StudentID) from Result r, Subject su, Student s
	where r.SubjectID =su.ID  and s.ID = r.StudentID and s.ClassID = @x and r.times > 2 and su.Name = N'Cơ sở dữ liệu'
	declare @a int
	select @a = COUNT(*) from Result r, Subject su, Student s
	where r.SubjectID = su.ID and su.Name = N'Cơ sở dữ liệu' and s.ID = r.StudentID and s.ClassID = @x and
	r.Mark >=5 and 
	r.Times >= all(select r1.times from Result r1, Subject su1, Student s1
					where r1.StudentID = r.StudentID and r1.SubjectID = su1.ID and su1.Name = N'Cơ sở dữ liệu' and s1.ID = r.StudentID and s1.ClassID = @x)
	if @b > @a/2.0
		set @kq = N'Đạt'
	else
		set @kq = N'Không đạt'	
end
--câu 3
alter table Teacher add danhgia nvarchar(30)
go
create proc	Cau3
@subjectID varchar(30)
as begin
	declare c cursor for select TeacherID from Ability where SubjectID = @subjectID
	declare @teacherID varchar(50)
	open c
	fetch next from c into @teacherID
	while @@FETCH_STATUS = 0
	begin
		declare @kq nvarchar(50)
		exec Cau2 @teacherID, @kq output
		update Teacher set danhgia = @kq where @teacherID = ID
		fetch next from c into @teacherID
	end
	close c
	deallocate c
end
