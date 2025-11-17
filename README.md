# Data Mart - Akademik  
Tugas Besar Pergudangan Data - Kelompok 2

## 👥 Team Members
- Tesalonika Hutajulu — 123450033  
- Rahmah Gustriana Deka — 123450102  
- Abit Ahmad Oktarian — 122450042  
- Sarah Wasti — 123450057  

## 📘 Project Description
Data Mart Akademik ini dirancang untuk mendukung analitik akademik secara komprehensif dalam institusi pendidikan.  
Fokus utama berada pada proses **admission**, **perkuliahan (enrollment)**, dan **kelulusan (graduation)**, sehingga dapat dipakai untuk memantau performa mahasiswa, efektivitas mata kuliah, kualitas pengajaran, serta efisiensi program studi.

Pendekatan **dimensional modeling (Kimball)** digunakan agar proses analisis cepat, konsisten, dan mudah diekspansi.

## 🏫 Business Domain
Domain yang diangkat adalah **pengelolaan akademik**, mencakup seluruh lifecycle mahasiswa:
1. Pendaftaran masuk (Admission)
2. Aktivitas perkuliahan (Enrollment)
3. Kelulusan (Graduation)

Stakeholder utama:
- BAAK  
- Program Studi  
- Fakultas  
- Wakil Rektor Akademik  
- Dosen & Pengajar  

## 🏗️ Architecture
- **Approach:** Kimball Dimensional Modeling (Star Schema)  
- **Platform:** SQL Server on Azure VM  
- **ETL:** UBUNTU 24 
- **Orchestrator:** SQL Agent  
- **Analytical Layer:** Power BI  

## ⭐ Key Features

### 🧮 Fact Tables
1. **Fact_Enrollment**  
   *Grain: satu baris per mahasiswa per mata kuliah per semester*  
   - EnrollmentKey (PK)  
   - DateKey (FK → Dim_Date)  
   - StudentKey (FK → Dim_Student)  
   - CourseKey (FK → Dim_Course)  
   - InstructorKey (FK → Dim_Instructor)  
   - ProgramKey (FK → Dim_Program)  
   - SemesterKey (FK → Dim_Semester)  
   - Grade  
   - Credits  
   - AttendanceRate  
   - TuitionFee  

2. **Fact_Admission**  
   *Grain: satu baris per pendaftar/pendaftaran*  
   - AdmissionKey (PK)  
   - DateKey  
   - StudentKey  
   - AdmissionType  
   - AdmissionScore  
   - AdmissionStatus  

3. **Fact_Graduation**  
   *Grain: satu baris per mahasiswa yang lulus*  
   - GraduationKey (PK)  
   - StudentKey  
   - DateKey  
   - TimeToGraduate  
   - Degree  
   - HonorsFlag  

---

### 📚 Dimension Tables
1. **Dim_Date**  
   - DateKey (PK)  
   - Date  
   - Day  
   - Month  
   - Quarter  
   - Year  
   - SemesterCode  

2. **Dim_Student**  
   - StudentKey (PK)  
   - StudentNaturalID (NIM)  
   - FullName  
   - DOB  
   - Gender  
   - EntryYear  
   - Status  
   - ProgramNaturalID  

3. **Dim_Course**  
   - CourseKey (PK)  
   - CourseCode  
   - CourseName  
   - Credits  
   - ProgramNaturalID  

4. **Dim_Instructor**  
   - InstructorKey (PK)  
   - InstructorNaturalID  
   - Name  
   - Rank  
   - Dept  
   - FTE  

5. **Dim_Program**  
   - ProgramKey (PK)  
   - ProgramCode  
   - ProgramName  
   - Faculty  

6. **Dim_Semester**  
   - SemesterKey (PK)  
   - SemesterCode  
   - StartDate  
   - EndDate  

---

## 📊 KPIs
- Average Grade per course & semester  
- Course pass rate  
- Attendance performance  
- Time-to-graduate  
- Admission conversion rate  
- Graduation rate  
- Attrition/Dropout rate  

---

## 📂 Documentation  
- **Business Requirements**  
  `/01-business-requirements/`

- **Design Documents**  
  `/02-data-modeling/`  

---

## ⏳ Timeline
- **Misi 1:** 10 November 2025  
- **Misi 2:** 17 November 2025  
- **Misi 3:** 24 November 2025  

---

# Data Mart - Akademik  
Tugas Besar Pergudangan Data - Kelompok 2

