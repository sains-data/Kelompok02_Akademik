CREATE SCHEMA stg;
GO

-- Staging Program
CREATE TABLE stg.Program (
    ProgramCode  VARCHAR(20),
    ProgramName  VARCHAR(100),
    Faculty      VARCHAR(100),
    LoadDate     DATETIME DEFAULT GETDATE()
);
GO

-- Staging Student
CREATE TABLE stg.Student (
    StudentNaturalID VARCHAR(20),
    FullName         VARCHAR(100),
    DOB              DATE,
    Gender           CHAR(1),
    EntryYear        INT,
    [Status]         VARCHAR(20),
    ProgramNaturalID VARCHAR(20),
    LoadDate         DATETIME DEFAULT GETDATE()
);
GO

-- Staging Course
CREATE TABLE stg.Course (
    CourseCode       VARCHAR(20),
    CourseName       VARCHAR(150),
    Credits          INT,
    ProgramNaturalID VARCHAR(20),
    LoadDate         DATETIME DEFAULT GETDATE()
);
GO

-- Staging Instructor
CREATE TABLE stg.Instructor (
    InstructorNaturalID VARCHAR(20),
    [Name]              VARCHAR(100),
    [Rank]              VARCHAR(50),
    Dept                VARCHAR(100),
    FTE                 DECIMAL(3,2),
    LoadDate            DATETIME DEFAULT GETDATE()
);
GO

-- Staging Enrollment (Fact)
CREATE TABLE stg.Enrollment (
    StudentNaturalID VARCHAR(20),
    CourseCode       VARCHAR(20),
    InstructorID     VARCHAR(20),
    SemesterCode     VARCHAR(20),
    DateKey          INT,
    Grade            VARCHAR(2),
    NumericGrade     DECIMAL(4,2),
    AttendanceRate   DECIMAL(5,2),
    [Status]         VARCHAR(20),
    LoadDate         DATETIME DEFAULT GETDATE()
);
GO
