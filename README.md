# SEGi Timetable System 
Automatic timetable generated PDF:
!i[image alt]()
![image alt](https://github.com/Rafia-Binte-Rezaul/Timetable-generating-system/blob/bb90da8b7aa7fd1ef7793e78d12741ba84d25b98/homepage.png)

This project integrates the SEGi Timetable System with a MySQL database using PHP and phpMyAdmin.

## Database Structure

The system uses the following database structure:

### Tables
- **departments** - Academic departments (SOCIT, SOB, SOM)
- **programmes** - Study programmes (DCS, DIIT, CIT, BCS, FIIT, BIT, UHAI, UHCS)
- **teachers** - Teacher information and specializations
- **subjects** - Course catalog with new/legacy codes
- **timetables** - Generated timetable metadata
- **timetable_entries** - Individual timetable schedule entries

## Setup Instructions

### Prerequisites
- XAMPP, WAMP, or MAMP (PHP + MySQL + Apache)
- Web browser
- phpMyAdmin access

### Step 1: Start Your Local Server
1. Start XAMPP/WAMP/MAMP
2. Ensure Apache and MySQL services are running
3. Open phpMyAdmin (usually at `http://localhost/phpmyadmin`)

### Step 2: Create Database
1. In phpMyAdmin, create a new database named `segi_project`
2. Set charset to `utf8mb4_unicode_ci`

### Step 3: Import Database Structure
1. Select the `segi_project` database
2. Go to the "Import" tab
3. Choose the `database_setup.sql` file from this directory
4. Click "Go" to execute

### Step 4: Configure Database Connection
1. Open `config.php` in this directory
2. Update the database credentials if needed:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'root');        // Your MySQL username
   define('DB_PASS', '');            // Your MySQL password
   define('DB_NAME', 'segi_project');
   ```

### Step 5: Test the Connection
1. Open your web browser
2. Navigate to `http://localhost/[your-project-path]/test_db.php`
3. Verify all tests pass (green checkmarks)

### Step 6: Use the System
If all tests pass, you can now use:
- **Teachers Management**: `teachers_db.html` - Add, edit, delete teachers
- **Dashboard**: `index.html` - Main dashboard
- **Course Selection**: `subjects.html` - Generate timetables

## File Structure

```
database/
├── config.php                 # Database configuration
├── setup_database.php         # PHP setup script
├── database_setup.sql          # SQL setup script
├── test_db.php                # Connection test page
├── teachers_db.html           # Database-connected teachers page
├── api/                       # API endpoints
│   ├── teachers.php           # Teachers CRUD operations
│   ├── subjects.php           # Subjects CRUD operations
│   ├── timetables.php         # Timetables CRUD operations
│   └── general.php            # General data (departments, programmes)
└── [existing HTML files]      # Your existing pages
```

## API Endpoints

### Teachers API (`api/teachers.php`)
- **GET** - Retrieve all teachers
- **POST** - Add new teacher
- **PUT** - Update existing teacher
- **DELETE** - Remove teacher (soft delete)

### Subjects API (`api/subjects.php`)
- **GET** - Retrieve subjects (all or by programme)
- **POST** - Add new subject
- **PUT** - Update existing subject
- **DELETE** - Remove subject

### Timetables API (`api/timetables.php`)
- **GET** - Retrieve saved timetables
- **POST** - Save new timetable
- **PUT** - Update timetable status
- **DELETE** - Remove timetable

### General API (`api/general.php`)
- **GET** `?type=departments` - Get all departments
- **GET** `?type=programmes` - Get all programmes
- **GET** `?type=department-programmes` - Get department-programme mapping

## Sample Data Included

The system comes with pre-populated sample data:

### Departments
- **SOCIT** - School of Computing and IT
- **SOB** - School of Business  
- **SOM** - School of Medicine

### Programmes
- **DCS** - Diploma in Computer Science
- **DIIT** - Diploma in Information Technology
- **CIT** - Certificate in Information Technology
- **BCS** - Bachelor of Computer Science
- **FIIT** - Foundation in Information Technology

### Sample Teachers
- Dr. Ahmad Rahman (Programming, Software Engineering)
- Ms. Siti Nurhaliza (Web Development, UI/UX)
- Mr. Raj Kumar (Networking, Cybersecurity)
- Dr. Lisa Wong (Data Science, AI/ML)
- Mr. Hassan Ali (Operating Systems)
- Ms. Priya Sharma (Mathematics, Statistics)
- Prof. David Tan (Project Management)

### Subjects
Complete DIIT curriculum with both new and legacy course codes, plus sample subjects for other programmes.

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check if MySQL is running
   - Verify credentials in `config.php`
   - Ensure database `segi_project` exists

2. **Tables Not Found**
   - Import the `database_setup.sql` file
   - Check if import was successful in phpMyAdmin

3. **API Errors**
   - Check PHP error logs
   - Ensure API files have correct permissions
   - Verify database connection

4. **CORS Issues** 
   - All API files include CORS headers
   - Test from same domain/localhost

### Testing Individual Components

1. **Database Connection**: Visit `test_db.php`
2. **Teacher Management**: Visit `teachers_db.html`
3. **API Endpoints**: Test with browser or Postman
   - `api/teachers.php` (GET request)
   - `api/general.php?type=departments`

## Next Steps

1. **Integrate More Pages**: Connect `subjects.html`, `view_timetables.html` to database
2. **Add Authentication**: Implement user login/logout
3. **Enhance UI**: Add more interactive features
4. **Backup System**: Implement database backup/restore
5. **Reporting**: Add detailed reports and analytics

## Recent Updates

### Certificate Program (CIT) Enhancement
- Updated `ciit_new.csv` with comprehensive Certificate in Information Technology subjects (28 subjects)
- Updated `ciit_old.csv` with legacy Certificate curriculum including additional subjects (38 subjects)
- Both files now follow the same structure as DIIT CSV files with proper subject codes (CIT prefix)
- Added curriculum differences between new and old programs:
  - Old curriculum includes: CIT1113 (Introduction to Information Technology), CIT1253 (Computer Organization), CIT1263 (Discrete Mathematics), CIT1353 (Human Computer Interaction), CIT2153 (Database Application Development), and additional advanced subjects
  - Files are now properly formatted as UTF-8 CSV instead of binary format

### Foundation Program (FIIT) Enhancement
- Updated `fiit.csv` with comprehensive Foundation in Information Technology subjects (15 subjects)
- Added core foundation subjects: Basic Mathematics, Computer Fundamentals, Introduction to Programming, Study Skills, Digital Literacy, Basic Statistics
- Includes all MPU (university mandatory) subjects for foundation level
- File converted from binary to properly formatted UTF-8 CSV
- Database now contains complete FIIT curriculum with 15 subjects total

### Bachelor and Diploma Programs (BIT & DCS) Enhancement
- Created `bit.csv` with comprehensive Bachelor of Information Technology subjects (31 subjects)
- Updated `dicssc_new.csv` with comprehensive Diploma in Computer Science subjects (31 subjects)
- Added new BIT programme to SOCIT department covering advanced IT topics: Enterprise Systems, IT Governance, Capstone Project
- Enhanced DCS programme with modern computer science curriculum: AI, Machine Learning, Distributed Systems, Cybersecurity
- Both programmes include all required MPU subjects and proper credit hour assignments
- Files converted from binary to properly formatted UTF-8 CSV

### University of Hertfordshire AI Program (UHAI) Enhancement
- Created `uhai_new.csv` and `uhai_old.csv` with University of Hertfordshire Artificial Intelligence subjects (30 subjects each)
- Added new UHAI programme to SOCIT department covering specialized AI curriculum
- Advanced AI subjects: Advanced Artificial Intelligence, Social and Collective AI, Machine Learning and Neural Computing, Robotics
- Project-based learning: Two-part AI Project sequence and Industrial Training
- Specialized topics: Intelligent Adaptive Systems, Responsible Computing, Software Architecture
- University-level MPU subjects with enhanced codes (MPU3xxx series)
- Files converted from original format to standardized UTF-8 CSV

### University of Hertfordshire Cyber Security Program (UHCS) Enhancement
- Created `uhcs_new.csv` and `uhcs_old.csv` with University of Hertfordshire Cyber Security subjects (30 subjects each)
- Added new UHCS programme to SOCIT department covering specialized cyber security curriculum
- Core security subjects: Cyber Security, Information Security Management, Network Protocols and Architectures
- Project-based learning: Two-part Cyber Security and Networks Projects sequence and Industrial Training
- Advanced security topics: Incident Response Digital Forensics, Software Architecture, Responsible Computing
- Industry integration: Technopreneurship and comprehensive computing foundation
- University-level MPU subjects with enhanced codes (MPU3xxx series)
- Files converted from original binary format to standardized UTF-8 CSV format

## Security Notes

- Change default database credentials
- Use prepared statements (already implemented)
- Validate all user inputs
- Implement proper authentication for production
- Use HTTPS in production environment

## Support

If you encounter issues:
1. Check the `test_db.php` page for diagnostics
2. Review PHP error logs
3. Verify database structure in phpMyAdmin
4. Ensure all files are in correct locations

---
*SEGi College Kuala Lumpur - Timetable Management System*
