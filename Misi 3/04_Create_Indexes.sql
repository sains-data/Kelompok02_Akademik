--------------------------------
-- NONCLUSTERED INDEXES
--------------------------------

CREATE NONCLUSTERED INDEX IX_Fact_Enrollment_DateKey
ON dbo.Fact_Enrollment(DateKey, EnrollmentID);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Graduation_DateKey
ON dbo.Fact_Graduation(GraduationDateKey, GraduationID);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Admission_DateKey
ON dbo.Fact_Admission(AdmissionDateKey, AdmissionID);
GO

-- Fact_Enrollment
CREATE NONCLUSTERED INDEX IX_Fact_Enroll_Student
ON dbo.Fact_Enrollment(StudentKey)
INCLUDE (CourseKey, SemesterKey, NumericGrade);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Enroll_Course
ON dbo.Fact_Enrollment(CourseKey)
INCLUDE (StudentKey, NumericGrade, AttendanceRate);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Enroll_Semester
ON dbo.Fact_Enrollment(SemesterKey, DateKey)
INCLUDE (StudentKey, CourseKey);
GO

-- Fact_Graduation
CREATE NONCLUSTERED INDEX IX_Fact_Grad_Student
ON dbo.Fact_Graduation(StudentKey)
INCLUDE (GPA, TotalCredits, StudyDuration);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Grad_Program
ON dbo.Fact_Graduation(ProgramKey, GraduationDateKey);
GO

-- Fact_Admission
CREATE NONCLUSTERED INDEX IX_Fact_Adm_Student
ON dbo.Fact_Admission(StudentKey)
INCLUDE (AdmissionStatus, AdmissionType);
GO

CREATE NONCLUSTERED INDEX IX_Fact_Adm_Program
ON dbo.Fact_Admission(ProgramKey, AdmissionDateKey)
INCLUDE (AdmissionStatus);
GO