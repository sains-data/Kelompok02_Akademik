-- 07_ETL_Procedures.sql

-- Load Dim_Program
CREATE OR ALTER PROCEDURE dbo.usp_Load_Dim_Program
AS
BEGIN
    MERGE dbo.Dim_Program AS tgt
    USING (
        SELECT DISTINCT ProgramCode, ProgramName, Faculty 
        FROM stg.Program
    ) AS src
    ON tgt.ProgramCode = src.ProgramCode
    WHEN MATCHED THEN
        UPDATE SET
            ProgramName = src.ProgramName,
            Faculty     = src.Faculty
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ProgramCode, ProgramName, Faculty)
        VALUES (src.ProgramCode, src.ProgramName, src.Faculty);
END;
GO


-- Load Dim_Student
CREATE OR ALTER PROCEDURE dbo.usp_Load_Dim_Student
AS
BEGIN
    MERGE dbo.Dim_Student AS tgt
    USING (
        SELECT DISTINCT
            StudentNaturalID, FullName, DOB, Gender,
            EntryYear, [Status], ProgramNaturalID
        FROM stg.Student
    ) AS src
    ON tgt.StudentNaturalID = src.StudentNaturalID
    WHEN MATCHED THEN 
        UPDATE SET
            FullName         = src.FullName,
            DOB              = src.DOB,
            Gender           = src.Gender,
            EntryYear        = src.EntryYear,
            [Status]         = src.[Status],
            ProgramNaturalID = src.ProgramNaturalID
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (StudentNaturalID, FullName, DOB, Gender,
                EntryYear, [Status], ProgramNaturalID)
        VALUES (src.StudentNaturalID, src.FullName, src.DOB,
                src.Gender, src.EntryYear, src.[Status],
                src.ProgramNaturalID);
END;
GO

-- Load Fact_Enrollment
CREATE OR ALTER PROCEDURE dbo.usp_Load_Fact_Enrollment
AS
BEGIN
    INSERT INTO dbo.Fact_Enrollment (
        StudentKey, CourseKey, SemesterKey, InstructorKey,
        DateKey, Grade, NumericGrade, AttendanceRate, [Status]
    )
    SELECT
        s.StudentKey,
        c.CourseKey,
        sem.SemesterKey,
        i.InstructorKey,
        e.DateKey,
        e.Grade,
        e.NumericGrade,
        e.AttendanceRate,
        e.[Status]
    FROM stg.Enrollment e
    JOIN dbo.Dim_Student   s   ON e.StudentNaturalID = s.StudentNaturalID
    JOIN dbo.Dim_Course    c   ON e.CourseCode       = c.CourseCode
    JOIN dbo.Dim_Instructor i  ON e.InstructorID     = i.InstructorNaturalID
    JOIN dbo.Dim_Semester  sem ON e.SemesterCode     = sem.SemesterCode
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Fact_Enrollment fe
        WHERE fe.StudentKey = s.StudentKey
          AND fe.CourseKey  = c.CourseKey
          AND fe.DateKey    = e.DateKey
    );
END;
GO
