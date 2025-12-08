-- 02_Create_Dimensions.sql
USE DM_AKADEMIK;
GO

-- Dim_Program
CREATE TABLE dbo.Dim_Program (
    ProgramKey       INT IDENTITY(1,1) PRIMARY KEY,
    ProgramCode      VARCHAR(20)  NOT NULL,
    ProgramName      VARCHAR(100) NOT NULL,
    Faculty          VARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Dim_Program_Code UNIQUE (ProgramCode)
);
GO

-- Dim_Date
CREATE TABLE dbo.Dim_Date (
    DateKey       INT PRIMARY KEY,       -- yyyymmdd
    [Date]        DATE NOT NULL,
    [Day]         INT  NOT NULL,
    [Month]       INT  NOT NULL,
    [Quarter]     INT  NOT NULL,
    [Year]        INT  NOT NULL,
    SemesterCode  VARCHAR(20) NULL,
    CONSTRAINT UQ_Dim_Date UNIQUE ([Date]),
    CONSTRAINT CHK_Dim_Date_Month   CHECK ([Month] BETWEEN 1 AND 12),
    CONSTRAINT CHK_Dim_Date_Quarter CHECK ([Quarter] BETWEEN 1 AND 4)
);
GO

-- Dim_Semester
CREATE TABLE dbo.Dim_Semester (
    SemesterKey  INT IDENTITY(1,1) PRIMARY KEY,
    SemesterCode VARCHAR(20) NOT NULL,
    StartDate    DATE NOT NULL,
    EndDate      DATE NOT NULL,
    CONSTRAINT UQ_Dim_Semester_Code UNIQUE (SemesterCode),
    CONSTRAINT CHK_Dim_Semester_Dates CHECK (EndDate > StartDate)
);
GO

-- Dim_Student
CREATE TABLE dbo.Dim_Student (
    StudentKey       INT IDENTITY(1,1) PRIMARY KEY,
    StudentNaturalID VARCHAR(20) NOT NULL,   -- NIM
    FullName         VARCHAR(100) NOT NULL,
    DOB              DATE NOT NULL,
    Gender           CHAR(1) NOT NULL CHECK (Gender IN ('M','F')),
    EntryYear        INT NOT NULL,
    [Status]         VARCHAR(20) NOT NULL,
    ProgramNaturalID VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Dim_Student_NIM      UNIQUE (StudentNaturalID),
    CONSTRAINT CHK_Dim_Student_EntryYr CHECK (EntryYear >= 1900)
);
GO

-- Dim_Course
CREATE TABLE dbo.Dim_Course (
    CourseKey        INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode       VARCHAR(20) NOT NULL,
    CourseName       VARCHAR(150) NOT NULL,
    Credits          INT NOT NULL,
    ProgramNaturalID VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Dim_Course_Code UNIQUE (CourseCode),
    CONSTRAINT CHK_Dim_Course_Credits CHECK (Credits > 0)
);
GO

-- Dim_Instructor
CREATE TABLE dbo.Dim_Instructor (
    InstructorKey       INT IDENTITY(1,1) PRIMARY KEY,
    InstructorNaturalID VARCHAR(20) NOT NULL,
    [Name]              VARCHAR(100) NOT NULL,
    [Rank]              VARCHAR(50) NULL,
    Dept                VARCHAR(100) NULL,
    FTE                 DECIMAL(3,2) NOT NULL DEFAULT 1.00,
    CONSTRAINT UQ_Dim_Instructor_ID UNIQUE (InstructorNaturalID),
    CONSTRAINT CHK_Dim_Instructor_FTE CHECK (FTE BETWEEN 0 AND 1)
);
GO

--------------------------------
-- Seed data dimensi
--------------------------------

-- Dim_Program
INSERT INTO dbo.Dim_Program (ProgramCode, ProgramName, Faculty)
VALUES
('TI',  'Teknik Informatika',       'Fakultas Sains dan Teknologi'),
('SI',  'Sistem Informasi',        'Fakultas Sains dan Teknologi'),
('MI',  'Manajemen Informatika',   'Fakultas Vokasi'),
('KM',  'Kimia',                   'Fakultas Sains dan Teknologi'),
('FI',  'Fisika',                  'Fakultas Sains dan Teknologi');
GO

-- Dim_Date (tahun 2018–2025)
DECLARE @Start DATE = '2018-01-01';
DECLARE @End   DATE = '2025-12-31';

WHILE @Start <= @End
BEGIN
    INSERT INTO dbo.Dim_Date (DateKey, [Date], [Day], [Month], [Quarter], [Year], SemesterCode)
    VALUES (
        CONVERT(INT, FORMAT(@Start, 'yyyyMMdd')),
        @Start,
        DATEPART(DAY, @Start),
        DATEPART(MONTH, @Start),
        DATEPART(QUARTER, @Start),
        DATEPART(YEAR, @Start),
        NULL -- bisa diupdate nanti sesuai mapping semester
    );

    SET @Start = DATEADD(DAY, 1, @Start);
END;
GO

-- Dim_Semester
INSERT INTO dbo.Dim_Semester (SemesterCode, StartDate, EndDate)
VALUES
('2018-Ganjil', '2018-08-01', '2019-01-31'),
('2018-Genap',  '2019-02-01', '2019-07-31'),
('2019-Ganjil', '2019-08-01', '2020-01-31'),
('2019-Genap',  '2020-02-01', '2020-07-31'),
('2020-Ganjil', '2020-08-01', '2021-01-31'),
('2020-Genap',  '2021-02-01', '2021-07-31'),
('2021-Ganjil', '2021-08-01', '2022-01-31'),
('2021-Genap',  '2022-02-01', '2022-07-31'),
('2022-Ganjil', '2022-08-01', '2023-01-31'),
('2022-Genap',  '2023-02-01', '2023-07-31'),
('2023-Ganjil', '2023-08-01', '2024-01-31'),
('2023-Genap',  '2024-02-01', '2024-07-31');
GO

-- Dim_Instructor
INSERT INTO dbo.Dim_Instructor (
    InstructorNaturalID, [Name], [Rank], Dept, FTE
)
VALUES
('INS001', 'Dr. Andi',     'Lektor Kepala', 'Teknik Informatika', 1.00),
('INS002', 'Dr. Budi',     'Lektor',        'Sistem Informasi',   1.00),
('INS003', 'Dr. Citra',    'Lektor',        'Manajemen Informatika', 0.75),
('INS004', 'Dr. Diana',    'Guru Besar',    'Kimia',              1.00),
('INS005', 'Dr. Eko',      'Asisten Ahli',  'Fisika',             0.50),
('INS006', 'Dr. Fitri',    'Lektor',        'Teknik Informatika', 1.00),
('INS007', 'Dr. Gita',     'Lektor',        'Sistem Informasi',   1.00),
('INS008', 'Dr. Hasan',    'Lektor Kepala', 'Kimia',              1.00),
('INS009', 'Dr. Intan',    'Asisten Ahli',  'Fisika',             0.80),
('INS010', 'Dr. Joko',     'Lektor',        'Manajemen Informatika', 1.00);
GO

-- Dim_Course
INSERT INTO dbo.Dim_Course (CourseCode, CourseName, Credits, ProgramNaturalID)
VALUES
('TI101', 'Pengantar Pemrograman',        3, 'TI'),
('TI102', 'Struktur Data',                3, 'TI'),
('TI201', 'Basis Data',                   3, 'TI'),
('SI101', 'Dasar Sistem Informasi',       3, 'SI'),
('SI102', 'Analisis Proses Bisnis',       3, 'SI'),
('MI101', 'Algoritma dan Logika',         3, 'MI'),
('KM101', 'Kimia Dasar',                  3, 'KM'),
('KM201', 'Kimia Organik',                3, 'KM'),
('FI101', 'Fisika Dasar',                 3, 'FI'),
('FI201', 'Fisika Modern',                3, 'FI');
GO

--Dim_Student (1.000 mahasiswa)
;WITH N AS (
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO dbo.Dim_Student (
    StudentNaturalID, FullName, DOB, Gender, EntryYear, [Status], ProgramNaturalID
)
SELECT
    CONCAT('NIM', RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)) AS StudentNaturalID,
    CONCAT('Mahasiswa ', n) AS FullName,
    DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 9000), '2000-01-01') AS DOB,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN 'M' ELSE 'F' END AS Gender,
    2018 + (ABS(CHECKSUM(NEWID())) % 6) AS EntryYear,  -- 2018–2023
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 80 THEN 'Aktif'
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 90 THEN 'Cuti'
        ELSE 'Lulus'
    END AS [Status],
    CASE 
        WHEN n % 5 = 1 THEN 'TI'
        WHEN n % 5 = 2 THEN 'SI'
        WHEN n % 5 = 3 THEN 'MI'
        WHEN n % 5 = 4 THEN 'KM'
        ELSE 'FI'
    END AS ProgramNaturalID;
GO
