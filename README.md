# Data Mart Akademik – Institut Teknologi Sumatera

Sistem Data Mart Akademik ini dikembangkan sebagai platform analitik terpusat untuk mendukung pengambilan keputusan strategis hingga operasional pada Unit Akademik Institut Teknologi Sumatera. Proyek ini mengintegrasikan data dari berbagai sumber seperti SIAKAD, API Insightera, data fakultas, dan data manual, kemudian mengubahnya menjadi informasi yang terstruktur melalui pendekatan **Dimensional Modeling (Kimball)** dan proses **ETL** yang sistematis.

Data Mart ini mencakup seluruh siklus hidup mahasiswa, mulai dari **Penerimaan**, **Perkuliahan**, hingga **Kelulusan**, serta mendukung evaluasi retensi, drop-out, dan performa pembelajaran.

---

# 📌 Ringkasan Proyek

Proyek ini membangun sebuah Data Mart Akademik yang berfungsi sebagai *single source of truth* bagi data akademik. Data diolah dari berbagai sistem operasional, distandarisasi melalui tabel staging, kemudian dimuat ke dalam struktur **Star Schema** yang terdiri dari tabel fakta dan dimensi.

Sistem ini memungkinkan:
- Analisis strategis dan operasional
- Monitoring performa mahasiswa
- Evaluasi efektivitas program studi
- Pelaporan yang konsisten dan terstruktur
- Dashboard interaktif berbasis Power BI

---

# 👥 Team Members

| NIM | Name | Role |
|-----|----------------------------|-------------------------------|
| 122450042 | Abit Ahmad Oktarian | Project Lead & Database Designer & ETL Developer |
| 123450033 | Tesalonika Hutajulu | ETL Developer |
| 123450102 | Rahmah Gustriana Deka | BI Developer |
| 123450057 | Sarah Wasti | Documentation & QA |

---

# 🏛️ Business Domain

Data Mart ini berfokus pada manajemen akademik meliputi pendaftaran mahasiswa baru, aktivitas pembelajaran, penilaian, hingga kelulusan.

## **Key Business Processes**
- Penerimaan Mahasiswa Baru (Admission)
- Perkuliahan & Pengajaran
- Evaluasi Akademik
- Kelulusan
- Mutasi / Drop-Out / Cuti Akademik

## **Stakeholders**
### Eksekutif (Strategic Level)
- Rektor
- Wakil Rektor Bidang Akademik
- Dekan

### Manajemen Unit (Tactical Level)
- Kaprodi
- Kepala Unit Akademik
- Kepala Biro Akademik

### Operasional (Operational Level)
- Staf Administrasi Akademik
- Unit PMB

---

# 🎯 Project Objectives

1. Menyediakan platform analitik akademik terpusat untuk pengambilan keputusan.
2. Membangun model dimensional (Star Schema) untuk analisis multidimensi.
3. Mengimplementasikan ETL otomatis dan terjadwal.
4. Membangun dashboard KPI akademik yang interaktif.
5. Meningkatkan kualitas data melalui Data Quality Checks.
6. Meningkatkan efisiensi perkuliahan dan proses akademik dengan insight berbasis data.

---

# 🧩 Analytical Questions (Use Cases)

Proyek ini dirancang untuk menjawab lebih dari 20 pertanyaan analitik, antara lain:

## Admission
1. Tren penerimaan mahasiswa per tahun?
2. Yield rate: berapa pendaftar yang daftar ulang?
3. Jalur seleksi paling efektif?
4. Prodi dengan pendaftar tertinggi?

## Academic Performance
1. Prodi dengan IPK tertinggi & terendah?
2. Distribusi nilai per mata kuliah?
3. Korelasi antara kehadiran dan nilai?
4. Mata kuliah paling sering gagal?
5. Identifikasi mahasiswa berisiko akademik.

## Retensi & Drop-Out
1. Indikator yang berpotensi memprediksi drop-out?
2. Drop-out rate per semester?
3. Semester kritis tempat drop-out terjadi?

## Graduation
1. Kelulusan tepat waktu?
2. Rata-rata lama studi per angkatan?
3. Tren kelulusan per prodi?
4. Jumlah lulusan cum laude?

## Operational Monitoring
1. Mahasiswa aktif per semester?
2. Tren SKS mahasiswa?
3. Kehadiran mahasiswa dan dosen?
4. Monitoring keterlambatan registrasi ulang.

---

# 📈 Key Performance Indicators (KPIs)

### **Tingkat Institusi**
- Jumlah mahasiswa aktif per tahun akademik
- Tren penerimaan mahasiswa baru per tahun
- Tingkat drop-out per angkatan

### **Tingkat Program Studi**
- Rata-rata IPK/IPS per semester & angkatan
- Kelulusan tepat waktu
- Rasio dosen terhadap mahasiswa
- Persentase mahasiswa dengan beban studi minimal/optimal

### **Operasional Akademik**
- Kehadiran mahasiswa & dosen
- Distribusi nilai A–E
- Jumlah pengulangan mata kuliah
- Lama studi rata-rata

---

# 🧱 Requirements

## Functional Requirements
- Manajemen tabel dimensi & fakta
- ETL extraction-transform-load pipeline
- KPI computation logic
- Reporting & dashboard

## Non-Functional Requirements
- Performance (Indexing & Partitioning)
- Security (RBAC, Audit Trail, Data Masking)
- Reliability (Backup & Recovery)
- Scalability

---

# 🏗️ Data Architecture

## Approach: **Star Schema (Dimensional Modeling)**

![Dimensional Model](docs/02-design/dimensional-model.png)

---

# 🧩 Grain Definition

### Fact_Admission  
Satu baris = **satu aplikasi pendaftaran**.

### Fact_Enrollment  
Satu baris = **satu mahasiswa mengambil satu mata kuliah pada satu semester**.

### Fact_Graduation  
Satu baris = **satu mahasiswa lulus**.

---

# 📦 Fact & Dimension Tables

## Fact Tables
### **Fact_Admission**
- TestScore  
- InterviewScore  
- HighSchoolGPA  
- ProcessingDays  

### **Fact_Enrollment**
- NumericGrade  
- Grade (A–E)  
- AttendanceRate  
- Credits  

### **Fact_Graduation**
- GPA (IPK Akhir)  
- ThesisScore  
- TotalCredits  
- StudyDuration (bulan)  

## Dimension Tables
### Dim_Student
- StudentKey (Surrogate)
- StudentNaturalID (NIM)
- FullName
- Gender
- EntryYear

### Dim_Program
- ProgramName
- Faculty

### Dim_Course
- CourseCode
- CourseName
- Credits

### Dim_Instructor
- Name
- Rank
- FTE

### Dim_Semester
- SemesterCode
- StartDate
- EndDate

### Dim_Date
- Date, Month, Quarter, Year

---

# 🛠️ Physical Design

## Key Elements
- Surrogate Keys (INT IDENTITY)
- DateKey stored as INT (YYYYMMDD)
- Numeric attributes: DECIMAL for precision
- Check constraints for logical validation (grade range, attendance)

---

# ⚙️ Indexing Strategy

1. **Primary Key Clustered Index** pada semua dimensi.
2. **Non-Clustered Index** pada kolom foreign key.
3. **Columnstore Index** pada tabel fakta besar (Fact_Enrollment).
4. **Partitioning** berdasarkan Academic Year menggunakan:
   - Partition Function: PF_AcademicYear
   - Partition Scheme: PS_AcademicYear

---

# 🔄 ETL Architecture

## ETL Flow:
1. Extract → load to **staging tables** (stg.*)
2. Transform → standardization, cleaning, deduplication
3. Load → Dim tables (MERGE), Fact tables (incremental)

## Tools:
- T-SQL Stored Procedures
- SQL Server Agent (scheduling)

---

# 📊 Dashboard Development

Dashboard dibangun menggunakan Power BI dengan struktur:

### 1. Executive Dashboard
- Total mahasiswa aktif  
- Tren penerimaan  
- Kelulusan tepat waktu  

### 2. Academic Performance Dashboard
- Distribusi nilai  
- Rata-rata IPK/IPS  
- Kehadiran mahasiswa  

### 3. Admission Funnel
- Pendaftar → Lolos → Registrasi Ulang  

### 4. Operational Dashboard
- Beban dosen  
- Beban studi mahasiswa  
- Mata kuliah pengulang terbanyak  

---

# 🔐 Security Implementation

- Role-Based Access Control  
  Roles:  
  - `db_executive`  
  - `db_analyst`  
  - `db_viewer`  
  - `db_etl_operator`  

- Dynamic Data Masking untuk email dan nomor telepon mahasiswa  
- Audit Trail INSERT/UPDATE/DELETE pada tabel fakta  
- Backup Strategy:
  - Full Backup Mingguan
  - Differential Harian
  - Log Backup 6 jam sekali  

---

# 🧪 Testing & Validation

## Data Quality Checks
- Completeness  
- Referential Integrity  
- Range & consistency checks  
- Anomaly detection  

## Performance Testing
- Query execution benchmarking  
- ETL duration measurement  
- Multi-user load simulation  

## UAT (User Acceptance Testing)
Dilakukan bersama Unit Akademik dengan skenario nyata:
- Evaluasi nilai
- Monitoring kelas
- Analisis prodi

---

# 🚀 Deployment & Operations

## Deployment Environment
- Azure Virtual Machine (Ubuntu 24 + SQL Server)
- ETL schedules via SQL Server Agent
- Access melalui Azure Bastion (secure entrypoint)

## Monitoring
- Query performance  
- ETL logs  
- Server CPU, memory & IO  

## Maintenance
- Data cleanup  
- Index rebuild  
- Monitoring storage growth  

---

# 📚 Documentation Structure
docs/
├── 01-MISI 1/
├── 02-MISI 2/
├── 03-MISI 3/
└── 04-REVISI/

---

# 📅 Project Timeline

| Phase | Description | Status |
|-------|-------------|--------|
| **Misi 1** | Conceptual & Logical Design | Completed |
| **Misi 2** | Physical Design & ETL | Completed |
| **Misi 3** | Deployment & Dashboard | Completed |

---

# 📜 License

Proyek ini merupakan bagian dari Tugas Besar Pergudangan Data – Program Studi Sains Data, ITERA.

---

# 🙌 Acknowledgments

- Program Studi Sains Data, Fakultas Sains  
- Dosen Pengampu  
- Unit Akademik ITERA  

---

# 📬 Contact

Silakan hubungi Project Lead atau buat *issue* di repository ini untuk pertanyaan maupun diskusi.


