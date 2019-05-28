--for debug
SELECT * FROM Actors

declare @i int = 11641;
while @i > 0
begin 
	update Actors set fname = NULL
	update Actors set lname = NULL
	set @i = @i - 1
end

--Tasks.sql

--a)
ALTER TABLE TechStaff ADD CONSTRAINT age_constraint check (age>=10 AND age<=125)
ALTER TABLE SoundTrack ADD CONSTRAINT song_constraint check ([duration(sec)] > 0)

--b)
ALTER TABLE Actors ADD fname char(255)
ALTER TABLE Actors ADD lname char(255)

update Actors 
set Actors.fname = REPLACE(B.fname, ' ', ''),
Actors.lname = REPLACE(B.lname, ' ', '')

from Actors as A inner join 

(select 
	fname = 
		case 
			when CHARINDEX(',', name) = 0 then 
				name
			else
				SUBSTRING(name, 1, CHARINDEX(',', name) - 1)
		end,

	lname =
		case 
			when CHARINDEX(',', name) = 0 then 
				null
			else
				SUBSTRING(name, CHARINDEX(',', name) + 1, LEN(name))
		end
	from Actors
) B on A.name = B.fname + 
case
	when B.lname is null then ''
else ',' + B.lname
end

--c)
UPDATE Studio
set employees = employeesNumber from (
	SELECT studioID, COUNT(*) AS employeesNumber
	FROM TechStaff
	GROUP BY studioID
) as ins where Studio.studioID = ins.studioID


--d)
CREATE FUNCTION EmployeeCount (@studioID integer)
returns integer
AS
begin
	DECLARE @result integer
	set @result = (
					SELECT COUNT (*)
					FROM TechStaff
					WHERE TechStaff.studioID = @studioID )
	RETURN @result
end

CREATE TRIGGER tr_update_employee
ON TechStaff 
AFTER INSERT, DELETE
AS
BEGIN
	DECLARE @id integer, @countEmp integer 
	If exists (Select * from inserted) 
	begin
		set @id = (
			SELECT studioID
			FROM inserted i
		)
	end
	If exists(select * from deleted)
	begin 
		set @id = (
			SELECT studioID
			FROM deleted i
			)
	end
	set @countEmp = dbo.EmployeeCount(@id)
	UPDATE Studio set employees = @countEmp WHERE studioID = @id
END

--e)
CREATE TRIGGER tr_deletedStudios_record
ON Studio
AFTER DELETE
AS
BEGIN
	if NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FoldedStudios')
	BEGIN
		CREATE TABLE FoldedStudios(
			studioName char(50),
			fired int
		)
	END
	if exists (SELECT * FROM deleted)
	BEGIN
		declare @sName char(50), @emp int
		set @sName = (SELECT studioName FROM deleted d)
		set @emp = (SELECT employees FROM deleted d) 
		INSERT INTO FoldedStudios VALUES (@sName, @emp)
	END
END

--f) use char will not work, use varchar only!! don't know why
CREATE PROC spSearchString 
@st varchar(20) 
AS
BEGIN
	SELECT k.keyword
	FROM Keywords k
	WHERE k.keyword LIKE @st+'%'
END
