-- 08_Data_Quality_Checks.sql
-----------------------------------
-- Data Quality Checks
-----------------------------------

-- 1. Completeness check
SELECT COUNT(*) AS NullName
FROM dbo.Dim_Student
WHERE FullName IS NULL;
GO

-- 2. Orphan check Fact <-> Dimension
SELECT COUNT(*) AS Orphan_Students
FROM dbo.Fact_Enrollment f
LEFT JOIN dbo.Dim_Student d ON f.StudentKey = d.StudentKey
WHERE d.StudentKey IS NULL;
GO

-- 3. Numeric grade validity
SELECT COUNT(*) AS InvalidGrades
FROM dbo.Fact_Enrollment
WHERE NumericGrade NOT BETWEEN 0 AND 4;
GO

-- 4. Duplicate fact combinations
SELECT StudentKey, CourseKey, SemesterKey, COUNT(*) AS Cnt
FROM dbo.Fact_Enrollment
GROUP BY StudentKey, CourseKey, SemesterKey
HAVING COUNT(*) > 1;
GO

-----------------------------------
-- Performance Testing / Analytical Queries
-----------------------------------

-- 1. Average grade per program per year
SELECT 
    p.ProgramName,
    d.[Year],
    AVG(f.NumericGrade) AS AvgGrade
FROM dbo.Fact_Enrollment f
JOIN dbo.Dim_Date d ON f.DateKey = d.DateKey
JOIN dbo.Dim_Course c ON f.CourseKey = c.CourseKey
JOIN dbo.Dim_Program p ON c.ProgramNaturalID = p.ProgramCode
GROUP BY p.ProgramName, d.[Year]
ORDER BY d.[Year], p.ProgramName;
GO

-- 2. Monthly enrollment trend
SELECT 
    d.[Year], d.[Month],
    COUNT(*) AS TotalEnrollments
FROM dbo.Fact_Enrollment f
JOIN dbo.Dim_Date d ON f.DateKey = d.DateKey
GROUP BY d.[Year], d.[Month]
ORDER BY d.[Year], d.[Month];
GO

-- 3. Funnel Admission → Enrollment → Graduation per Program per Tahun
;WITH Adm AS (
    SELECT
        a.ProgramKey,
        d.[Year] AS AdmissionYear,
        COUNT(DISTINCT a.StudentKey) AS TotalApplicants
    FROM dbo.Fact_Admission a
    JOIN dbo.Dim_Date d ON a.AdmissionDateKey = d.DateKey
    GROUP BY a.ProgramKey, d.[Year]
),
Enr AS (
    SELECT
        c.ProgramNaturalID,
        d.[Year] AS EnrollmentYear,
        COUNT(DISTINCT f.StudentKey) AS TotalEnrolled
    FROM dbo.Fact_Enrollment f
    JOIN dbo.Dim_Course c ON f.CourseKey = c.CourseKey
    JOIN dbo.Dim_Date d   ON f.DateKey   = d.DateKey
    GROUP BY c.ProgramNaturalID, d.[Year]
),
Grad AS (
    SELECT
        g.ProgramKey,
        d.[Year] AS GraduationYear,
        COUNT(DISTINCT g.StudentKey) AS TotalGraduated
    FROM dbo.Fact_Graduation g
    JOIN dbo.Dim_Date d ON g.GraduationDateKey = d.DateKey
    GROUP BY g.ProgramKey, d.[Year]
)
SELECT
    p.ProgramName,
    a.AdmissionYear,
    a.TotalApplicants,
    ISNULL(e.TotalEnrolled, 0)  AS TotalEnrolled,
    ISNULL(g.TotalGraduated, 0) AS TotalGraduated,
    CASE WHEN a.TotalApplicants = 0 
         THEN 0 ELSE 1.0 * ISNULL(e.TotalEnrolled, 0) / a.TotalApplicants END AS Conv_Adm_to_Enroll,
    CASE WHEN a.TotalApplicants = 0 
         THEN 0 ELSE 1.0 * ISNULL(g.TotalGraduated, 0) / a.TotalApplicants END AS Conv_Adm_to_Grad
FROM Adm a
JOIN dbo.Dim_Program p ON a.ProgramKey = p.ProgramKey
LEFT JOIN Enr e 
    ON p.ProgramCode = e.ProgramNaturalID
   AND a.AdmissionYear = e.EnrollmentYear
LEFT JOIN Grad g 
    ON a.ProgramKey   = g.ProgramKey
   AND a.AdmissionYear = g.GraduationYear
ORDER BY p.ProgramName, a.AdmissionYear;
GO

-- 4: Distribusi lama studi dan GPA per program
SELECT
    p.ProgramName,
    COUNT(*)                          AS TotalGraduates,
    AVG(g.GPA)                        AS AvgGPA,
    MIN(g.GPA)                        AS MinGPA,
    MAX(g.GPA)                        AS MaxGPA,
    AVG(CAST(g.StudyDuration AS FLOAT)) AS AvgStudyMonths,
    MIN(g.StudyDuration)             AS MinStudyMonths,
    MAX(g.StudyDuration)             AS MaxStudyMonths
FROM dbo.Fact_Graduation g
JOIN dbo.Dim_Program p ON g.ProgramKey = p.ProgramKey
GROUP BY p.ProgramName
ORDER BY p.ProgramName;
GO

-- 5: Top 10 mahasiswa per program (GPA + SKS)
;WITH GradDetail AS (
    SELECT
        g.StudentKey,
        s.StudentNaturalID,
        s.FullName,
        p.ProgramName,
        g.GPA,
        g.TotalCredits,
        ROW_NUMBER() OVER (
            PARTITION BY p.ProgramName
            ORDER BY g.GPA DESC, g.TotalCredits DESC
        ) AS rn
    FROM dbo.Fact_Graduation g
    JOIN dbo.Dim_Student s ON g.StudentKey = s.StudentKey
    JOIN dbo.Dim_Program p ON g.ProgramKey = p.ProgramKey
)
SELECT
    ProgramName,
    rn AS RankInProgram,
    StudentNaturalID,
    FullName,
    GPA,
    TotalCredits
FROM GradDetail
WHERE rn <= 10
ORDER BY ProgramName, rn;
GO

-- 6: Pengaruh Attendance terhadap NumericGrade
;WITH EnrBucket AS (
    SELECT
        CASE 
            WHEN AttendanceRate < 60 THEN '< 60%'
            WHEN AttendanceRate < 75 THEN '60–74%'
            WHEN AttendanceRate < 90 THEN '75–89%'
            ELSE '>= 90%'
        END AS AttendanceBucket,
        NumericGrade
    FROM dbo.Fact_Enrollment
    WHERE NumericGrade IS NOT NULL
)
SELECT
    AttendanceBucket,
    COUNT(*)                 AS TotalEnrollments,
    AVG(NumericGrade)        AS AvgGrade,
    MIN(NumericGrade)        AS MinGrade,
    MAX(NumericGrade)        AS MaxGrade
FROM EnrBucket
GROUP BY AttendanceBucket
ORDER BY 
    CASE AttendanceBucket
        WHEN '< 60%'  THEN 1
        WHEN '60–74%' THEN 2
        WHEN '75–89%' THEN 3
        WHEN '>= 90%' THEN 4
    END;
GO

-- 7: Trend enrollment per semester dan program
SELECT
    sem.SemesterCode,
    d.[Year],
    p.ProgramName,
    COUNT(*)                       AS TotalEnrollments,
    COUNT(DISTINCT f.StudentKey)   AS DistinctStudents,
    AVG(f.NumericGrade)            AS AvgGrade
FROM dbo.Fact_Enrollment f
JOIN dbo.Dim_Semester sem ON f.SemesterKey = sem.SemesterKey
JOIN dbo.Dim_Date d       ON f.DateKey     = d.DateKey
JOIN dbo.Dim_Course c     ON f.CourseKey   = c.CourseKey
JOIN dbo.Dim_Program p    ON c.ProgramNaturalID = p.ProgramCode
GROUP BY sem.SemesterCode, d.[Year], p.ProgramName
ORDER BY d.[Year], sem.SemesterCode, p.ProgramName;
GO
