-----------------------------------
-- Partition function & scheme
-----------------------------------

CREATE PARTITION FUNCTION PF_AcademicYear (INT)
AS RANGE RIGHT FOR VALUES
(
    20200801, -- 2020/2021
    20210801, -- 2021/2022
    20220801, -- 2022/2023
    20230801, -- 2023/2024
    20240801, -- 2024/2025
    20250801  -- 2025/2026
);
GO

CREATE PARTITION SCHEME PS_AcademicYear
AS PARTITION PF_AcademicYear
ALL TO ([PRIMARY]);
GO

-----------------------------------
-- Partitioned Fact_Enrollment table
-----------------------------------

IF OBJECT_ID('dbo.Fact_Enrollment_Partitioned', 'U') IS NOT NULL
    DROP TABLE dbo.Fact_Enrollment_Partitioned;
GO

CREATE TABLE dbo.Fact_Enrollment_Partitioned (
    EnrollmentID   INT IDENTITY(1,1) NOT NULL,
    StudentKey     INT NOT NULL,
    CourseKey      INT NOT NULL,
    SemesterKey    INT NOT NULL,
    InstructorKey  INT NOT NULL,
    DateKey        INT NOT NULL,
    Grade          VARCHAR(2)  NULL,
    NumericGrade   DECIMAL(4,2) NULL,
    AttendanceRate DECIMAL(5,2) NULL,
    [Status]       VARCHAR(20)  NULL,
    CONSTRAINT PK_Fact_Enrollment_Part
        PRIMARY KEY CLUSTERED (DateKey, EnrollmentID)
) ON PS_AcademicYear(DateKey);
GO