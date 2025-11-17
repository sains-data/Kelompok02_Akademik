# AKADEMIK-TubesDW-Kelompok02

# Data Mart - Akademik  
Tugas Besar Pergudangan Data - Kelompok 2

## 👥 Team Members
- Tesalonika Hutajulu — 123450033  
- Rahmah Gustriana Deka — 123450102  
- Abit Ahmad Oktarian — 122450042  
- Sarah Wasti — 123450057  

## 📘 Project Description
Data Mart Akademik ini dirancang untuk mendukung kebutuhan analitik di lingkungan institusi pendidikan.  
Proyek ini bertujuan menyediakan data terstruktur untuk analisis performa akademik mahasiswa, kinerja mata kuliah, efektivitas dosen, dan pemantauan progres studi secara keseluruhan.

Data Mart ini menggunakan pendekatan dimensional modeling sehingga memungkinkan pelaporan cepat, konsisten, dan mudah diadaptasi untuk berbagai kebutuhan analisis akademik.

## 🏫 Business Domain
Domain yang diangkat adalah **manajemen akademik**, mencakup:
- Aktivitas perkuliahan  
- Penilaian mahasiswa  
- Data program studi dan mata kuliah  
- Jadwal akademik  
- Aktivitas dosen  
- Presensi mahasiswa & dosen  

Data Mart ini akan mendukung unit seperti BAAK, Program Studi, dan pihak universitas dalam melakukan evaluasi kinerja akademik.

## 🏗️ Architecture
- **Approach:** Kimball (Dimensional Modeling / Star Schema)  
- **Platform:** SQL Server on Azure Virtual Machine  
- **ETL Tools:** SSIS (SQL Server Integration Services)  
- **Orchestration:** Stored Procedure + SQL Agent  
- **BI Layer:** Power BI (untuk dashboard & reporting)

## ⭐ Key Features
- **Fact Tables:**  
  - Fact_KHS  
  - Fact_Transkrip  
  - Fact_Presensi  
  - Fact_KRS  
  - Fact_Jadwal  

- **Dimension Tables:**  
  - Dim_Mahasiswa  
  - Dim_Dosen  
  - Dim_MataKuliah  
  - Dim_ProgramStudi  
  - Dim_Waktu  

- **KPIs:**  
  - Rata-rata IP per semester  
  - Tingkat kelulusan mata kuliah  
  - Distribusi nilai per mata kuliah  
  - Persentase presensi mahasiswa dan dosen  
  - Retensi dan dropout rate  

## 📂 Documentation  
- **Business Requirements:**  
  `/01-business-requirements/`

- **Design Documents:**  
  `/02-data-modeling/`  
  Berisi ERD, star schema, data dictionary, serta definisi fact & dimension.

## ⏳ Timeline
- **Misi 1:** 10 November 2025  
- **Misi 2:** 17 November 2025  
- **Misi 3:** 24 November 2025  

---

# Data Mart - Akademik  
Tugas Besar Pergudangan Data - Kelompok 2
