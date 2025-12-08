-- 03_Create_Facts.sql
USE DM_AKADEMIK;
GO

-- Fact_Enrollment
CREATE TABLE dbo.Fact_Enrollment (
    EnrollmentID   INT IDENTITY(1,1) PRIMARY KEY,
    StudentKey     INT NOT NULL,
    CourseKey      INT NOT NULL,
    SemesterKey    INT NOT NULL,
    InstructorKey  INT NOT NULL,
    DateKey        INT NOT NULL,
    Grade          VARCHAR(2)  NULL,
    NumericGrade   DECIMAL(4,2) NULL,
    AttendanceRate DECIMAL(5,2) NULL,
    [Status]       VARCHAR(20)  NULL,
    CONSTRAINT FK_Fact_Enroll_Student    FOREIGN KEY (StudentKey)    REFERENCES dbo.Dim_Student(StudentKey),
    CONSTRAINT FK_Fact_Enroll_Course     FOREIGN KEY (CourseKey)     REFERENCES dbo.Dim_Course(CourseKey),
    CONSTRAINT FK_Fact_Enroll_Semester   FOREIGN KEY (SemesterKey)   REFERENCES dbo.Dim_Semester(SemesterKey),
    CONSTRAINT FK_Fact_Enroll_Instructor FOREIGN KEY (InstructorKey) REFERENCES dbo.Dim_Instructor(InstructorKey),
    CONSTRAINT FK_Fact_Enroll_Date       FOREIGN KEY (DateKey)       REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT CHK_Fact_Enroll_Grade     CHECK (NumericGrade BETWEEN 0 AND 4),
    CONSTRAINT CHK_Fact_Enroll_Attend    CHECK (AttendanceRate BETWEEN 0 AND 100)
);
GO

-- Fact_Graduation
CREATE TABLE dbo.Fact_Graduation (
    GraduationID      INT IDENTITY(1,1) PRIMARY KEY,
    StudentKey        INT NOT NULL,
    DateKey           INT NOT NULL,          -- mis. tanggal yudisium
    ProgramKey        INT NOT NULL,
    GraduationDateKey INT NOT NULL,          -- tanggal wisuda
    GPA               DECIMAL(4,2) NOT NULL,
    TotalCredits      INT NOT NULL,
    StudyDuration     INT NULL,              -- bulan
    Honors            VARCHAR(50) NULL,
    ThesisScore       DECIMAL(5,2) NULL,
    CONSTRAINT FK_Fact_Grad_Student    FOREIGN KEY (StudentKey)        REFERENCES dbo.Dim_Student(StudentKey),
    CONSTRAINT FK_Fact_Grad_Date       FOREIGN KEY (DateKey)           REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT FK_Fact_Grad_GradDate   FOREIGN KEY (GraduationDateKey) REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT FK_Fact_Grad_Program    FOREIGN KEY (ProgramKey)        REFERENCES dbo.Dim_Program(ProgramKey),
    CONSTRAINT CHK_Fact_Grad_GPA       CHECK (GPA BETWEEN 0 AND 4),
    CONSTRAINT CHK_Fact_Grad_Credits   CHECK (TotalCredits > 0)
);
GO

-- Fact_Admission
CREATE TABLE dbo.Fact_Admission (
    AdmissionID        INT IDENTITY(1,1) PRIMARY KEY,
    StudentKey         INT NOT NULL,
    ProgramKey         INT NOT NULL,
    ApplicationDateKey INT NOT NULL,
    AdmissionDateKey   INT NOT NULL,
    TestScore          DECIMAL(5,2) NULL,
    InterviewScore     DECIMAL(5,2) NULL,
    HighSchoolGPA      DECIMAL(4,2) NULL,
    AdmissionStatus    VARCHAR(20) NOT NULL,
    AdmissionType      VARCHAR(50) NULL, -- SNMPTN/SBMPTN/Mandiri
    ProcessingDays     INT NULL,
    CONSTRAINT FK_Fact_Adm_Student    FOREIGN KEY (StudentKey)         REFERENCES dbo.Dim_Student(StudentKey),
    CONSTRAINT FK_Fact_Adm_Program    FOREIGN KEY (ProgramKey)         REFERENCES dbo.Dim_Program(ProgramKey),
    CONSTRAINT FK_Fact_Adm_AppDate    FOREIGN KEY (ApplicationDateKey) REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT FK_Fact_Adm_AdmDate    FOREIGN KEY (AdmissionDateKey)   REFERENCES dbo.Dim_Date(DateKey),
    CONSTRAINT CHK_Fact_Adm_Test      CHECK (TestScore      >= 0),
    CONSTRAINT CHK_Fact_Adm_Interview CHECK (InterviewScore >= 0),
    CONSTRAINT CHK_Fact_Adm_HSGPA     CHECK (HighSchoolGPA BETWEEN 0 AND 4)
);
GO

--------------------------------
-- Generate data Fact_Admission
--------------------------------
USE akademik;
GO

DECLARE @RowCountAdm INT = 8000;   -- ubah kalau mau jumlah lain

;WITH Numbers AS (
    SELECT TOP (@RowCountAdm)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects ao1
    CROSS JOIN sys.all_objects ao2
)
INSERT INTO dbo.Fact_Admission (
    StudentKey,
    ProgramKey,
    ApplicationDateKey,
    AdmissionDateKey,
    TestScore,
    InterviewScore,
    HighSchoolGPA,
    AdmissionStatus,
    AdmissionType,
    ProcessingDays
)
SELECT
    s.StudentKey,
    p.ProgramKey,
    app.DateKey        AS ApplicationDateKey,
    adm.DateKey        AS AdmissionDateKey,
    -- skor 0–100 (dua desimal)
    CAST((ABS(CHECKSUM(NEWID())) % 10001) / 100.0 AS DECIMAL(5,2)) AS TestScore,
    CAST((ABS(CHECKSUM(NEWID())) % 10001) / 100.0 AS DECIMAL(5,2)) AS InterviewScore,
    -- HighSchoolGPA 2.00–4.00
    CAST((200 + (ABS(CHECKSUM(NEWID())) % 201)) / 100.0 AS DECIMAL(4,2)) AS HighSchoolGPA,
    CASE 
        WHEN randStatus.RandStatus < 60 THEN 'Accepted'
        WHEN randStatus.RandStatus < 85 THEN 'Rejected'
        ELSE 'Waiting List'
    END AS AdmissionStatus,
    CASE 
        WHEN randType.RandType < 35 THEN 'SNMPTN'
        WHEN randType.RandType < 70 THEN 'SBMPTN'
        WHEN randType.RandType < 90 THEN 'Mandiri'
        ELSE 'Beasiswa'
    END AS AdmissionType,
    DATEDIFF(DAY, app.[Date], adm.[Date]) AS ProcessingDays
FROM Numbers n
-- ambil student + program natural ID-nya
CROSS APPLY (
    SELECT TOP 1 StudentKey, ProgramNaturalID
    FROM dbo.Dim_Student
    ORDER BY NEWID()
) AS s
-- map ProgramNaturalID -> ProgramKey
CROSS APPLY (
    SELECT TOP 1 ProgramKey
    FROM dbo.Dim_Program
    WHERE ProgramCode = s.ProgramNaturalID
    ORDER BY ProgramKey
) AS p
-- pilih application date (dibatasi supaya +60 hari masih dalam range dim tanggal)
CROSS APPLY (
    SELECT TOP 1 DateKey, [Date]
    FROM dbo.Dim_Date
    WHERE [Date] <= '2025-10-31'
    ORDER BY NEWID()
) AS app
-- random offset 0–60 hari
CROSS APPLY (
    SELECT ABS(CHECKSUM(NEWID())) % 61 AS DaysOffset
) AS ofs
-- admission date = application date + offset
CROSS APPLY (
    SELECT DateKey, [Date]
    FROM dbo.Dim_Date
    WHERE [Date] = DATEADD(DAY, ofs.DaysOffset, app.[Date])
) AS adm
-- random status dan admission type
CROSS APPLY (SELECT ABS(CHECKSUM(NEWID())) % 100 AS RandStatus) AS randStatus
CROSS APPLY (SELECT ABS(CHECKSUM(NEWID())) % 100 AS RandType)   AS randType;
GO

-- check hasilnya
SELECT COUNT(*) AS JumlahAdmission
FROM dbo.Fact_Admission;
GO

--------------------------------
-- Generate data Fact_Graduation
--------------------------------
USE akademik;
GO

DECLARE @RowCountGrad INT = 3000;   -- ubah kalau mau jumlah lain

;WITH Numbers AS (
    SELECT TOP (@RowCountGrad)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects ao1
    CROSS JOIN sys.all_objects ao2
)
INSERT INTO dbo.Fact_Graduation (
    StudentKey,
    DateKey,
    ProgramKey,
    GraduationDateKey,
    GPA,
    TotalCredits,
    StudyDuration,
    Honors,
    ThesisScore
)
SELECT
    s.StudentKey,
    yud.DateKey        AS DateKey,           -- tanggal yudisium
    p.ProgramKey,
    grad.DateKey       AS GraduationDateKey, -- tanggal wisuda
    -- GPA 2.00–4.00
    CAST((200 + (ABS(CHECKSUM(NEWID())) % 201)) / 100.0 AS DECIMAL(4,2)) AS GPA,
    -- total SKS 120–160
    120 + (ABS(CHECKSUM(NEWID())) % 41)  AS TotalCredits,
    -- lama studi 36–72 bulan
    36  + (ABS(CHECKSUM(NEWID())) % 37)  AS StudyDuration,
    CASE 
        WHEN randHonors.RandHonors < 50 THEN NULL
        WHEN randHonors.RandHonors < 80 THEN 'Cum Laude'
        WHEN randHonors.RandHonors < 95 THEN 'Magna Cum Laude'
        ELSE 'Summa Cum Laude'
    END AS Honors,
    -- nilai skripsi 60–100
    CAST((6000 + (ABS(CHECKSUM(NEWID())) % 4001)) / 100.0 AS DECIMAL(5,2)) AS ThesisScore
FROM Numbers n
-- ambil student + ProgramNaturalID
CROSS APPLY (
    SELECT TOP 1 StudentKey, ProgramNaturalID, EntryYear
    FROM dbo.Dim_Student
    WHERE [Status] = 'Lulus' OR [Status] = 'Aktif'
    ORDER BY NEWID()
) AS s
-- map ProgramNaturalID -> ProgramKey
CROSS APPLY (
    SELECT TOP 1 ProgramKey
    FROM dbo.Dim_Program
    WHERE ProgramCode = s.ProgramNaturalID
    ORDER BY ProgramKey
) AS p
-- pilih graduation date antara 2022–2025
CROSS APPLY (
    SELECT TOP 1 DateKey, [Date]
    FROM dbo.Dim_Date
    WHERE [Date] BETWEEN '2022-01-01' AND '2025-12-31'
    ORDER BY NEWID()
) AS grad
-- offset yudisium 0–90 hari sebelum wisuda
CROSS APPLY (
    SELECT ABS(CHECKSUM(NEWID())) % 91 AS OffsetDays
) AS ofs
CROSS APPLY (
    SELECT TOP 1 DateKey, [Date]
    FROM dbo.Dim_Date
    WHERE [Date] = DATEADD(DAY, -ofs.OffsetDays, grad.[Date])
    ORDER BY [Date]
) AS yud
CROSS APPLY (
    SELECT ABS(CHECKSUM(NEWID())) % 100 AS RandHonors
) AS randHonors;
GO

-- check jumlahnya
SELECT COUNT(*) AS JumlahGraduation
FROM dbo.Fact_Graduation;
GO
