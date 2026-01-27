-- SEGi Timetable System Database Setup
-- Execute these commands in phpMyAdmin or MySQL command line

-- Create database
CREATE DATABASE IF NOT EXISTS segi_project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE segi_project;

-- Create Departments table
CREATE TABLE IF NOT EXISTS departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Programmes table
CREATE TABLE IF NOT EXISTS programmes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    department_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- Create Teachers table
CREATE TABLE IF NOT EXISTS teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    department_id INT,
    specialization TEXT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    max_hours_per_week INT DEFAULT 18,
    break_time VARCHAR(20) DEFAULT 'None',
    off_days JSON DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- Create Subjects/Courses table
CREATE TABLE IF NOT EXISTS subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    new_code VARCHAR(20),
    legacy_code VARCHAR(20),
    name VARCHAR(200) NOT NULL,
    credit_hours INT DEFAULT 3,
    programme_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (programme_id) REFERENCES programmes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_subject_programme (code, programme_id)
);

-- Create Timetables table
CREATE TABLE IF NOT EXISTS timetables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    programme_id INT,
    study_mode ENUM('full-time', 'part-time') DEFAULT 'full-time',
    session VARCHAR(100),
    academic_year VARCHAR(20),
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (programme_id) REFERENCES programmes(id) ON DELETE CASCADE
);

-- Create Timetable Entries table
CREATE TABLE IF NOT EXISTS timetable_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timetable_id INT,
    subject_id INT,
    teacher_id INT,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
    start_time TIME,
    end_time TIME,
    venue VARCHAR(100),
    delivery_mode ENUM('Offline', 'Online') DEFAULT 'Offline',
    session_type ENUM('lecture', 'tutorial', 'standard') DEFAULT 'standard',
    cross_teaching BOOLEAN DEFAULT FALSE,
    duration_hours INT DEFAULT 3,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (timetable_id) REFERENCES timetables(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

-- Insert default departments
INSERT INTO departments (code, name) VALUES 
('SOCIT', 'School of Computing and IT'),
('SOB', 'School of Business'),
('SOM', 'School of Medicine');

-- Insert default programmes
INSERT INTO programmes (code, name, department_id) VALUES 
('DCS', 'Diploma in Computer Science', 1),
('DIIT', 'Diploma in Information Technology', 1),
('CIT', 'Certificate in Information Technology', 1),
('BCS', 'Bachelor of Computer Science', 1),
('FIIT', 'Foundation in Information Technology', 1),
('BIT', 'Bachelor of Information Technology', 1),
('UHAI', 'University of Hertfordshire Artificial Intelligence', 1),
('UHCS', 'University of Hertfordshire Cyber Security', 1);

-- Insert sample teachers
INSERT INTO teachers (name, email, phone, department_id, specialization) VALUES 
('Dr. Ahmad Rahman', 'ahmad.rahman@segi.edu.my', '+6012-3456789', 1, 'Programming, Software Engineering, Database Systems'),
('Ms. Siti Nurhaliza', 'siti.nurhaliza@segi.edu.my', '+6012-9876543', 1, 'Web Development, Mobile Applications, UI/UX Design'),
('Mr. Raj Kumar', 'raj.kumar@segi.edu.my', '+6013-1234567', 1, 'Networking, Cybersecurity, Cloud Computing'),
('Dr. Lisa Wong', 'lisa.wong@segi.edu.my', '+6014-7654321', 1, 'Data Science, Machine Learning, Artificial Intelligence'),
('Mr. Hassan Ali', 'hassan.ali@segi.edu.my', '+6015-2468135', 1, 'Operating Systems, Computer Architecture, System Administration'),
('Ms. Priya Sharma', 'priya.sharma@segi.edu.my', '+6016-3691472', 1, 'Mathematics, Statistics, Discrete Mathematics'),
('Prof. David Tan', 'david.tan@segi.edu.my', '+6017-1357924', 1, 'Project Management, Ethics in Computing, Research Methods');

-- Insert DIIT subjects (New Curriculum)
INSERT INTO subjects (code, new_code, legacy_code, name, credit_hours, programme_id) VALUES 
('DIT1123', 'DIT1123', 'DIT1123', 'Statistics and Probability', 3, 2),
('DIT1124', 'DIT1124', 'DIT1124', 'Programming Fundamentals', 4, 2),
('DIT1133', 'DIT1133', 'DIT1133', 'Database Fundamentals', 3, 2),
('DIT1143', 'DIT1143', 'DIT1143', 'Data Communication and Networking', 3, 2),
('MPU2183', 'MPU2183', 'MPU2183', 'Penghayatan Etika dan Peradaban', 3, 2),
('MPU2133', 'MPU2133', 'MPU2133', 'Bahasa Melayu Komunikasi 1', 3, 2),
('DIT1213', 'DIT1213', 'DIT1213', 'Internet of Things', 3, 2),
('DIT1223', 'DIT1223', 'DIT1223', 'Calculus and Algebra', 3, 2),
('DIT1233', 'DIT1233', 'DIT1233', 'System Analysis and Design Fundamentals', 3, 2),
('DIT1244', 'DIT1244', 'DIT1244', 'Web and Mobile Systems', 4, 2),
('MPU2243', 'MPU2243', 'MPU2243', 'Growth Mindset', 3, 2),
('MPU2213', 'MPU2213', 'MPU2213', 'Bahasa Kebangsaan A', 3, 2),
('DIT1313', 'DIT1313', 'DIT1313', 'Operating Systems', 3, 2),
('DIT1324', 'DIT1324', 'DIT1324', 'Cloud Computing', 4, 2),
('DIT1334', 'DIT1334', 'DIT1334', 'Object-Oriented Development', 4, 2),
('DIT1344', 'DIT1344', 'DIT1344', 'Advanced Networking', 4, 2),
('MPU2432', 'MPU2432', 'MPU2432', 'Co-curriculum: Sustainability Thinking', 2, 2),
('DIT2113', 'DIT2113', 'DIT2113', 'Computer Architecture', 3, 2),
('DIT2124', 'DIT2124', 'DIT2124', 'System Paradigms', 4, 2),
('DIT2133', 'DIT2133', 'DIT2133', 'Python Programming', 3, 2),
('DIT2144', 'DIT2144', 'DIT2144', 'User Experience Design', 4, 2),
('MPU2373', 'MPU2373', 'MPU2373', 'Integrity and Anti-Corruption', 3, 2),
('DIT2213', 'DIT2213', 'DIT2213', 'Project Management', 3, 2),
('DIT2214', 'DIT2214', 'DIT2214', 'Discrete Mathematics', 4, 2),
('DIT2234', 'DIT2234', 'DIT2234', 'Cybersecurity Fundamentals', 4, 2),
('DIT2243', 'DIT2243', 'DIT2243', 'Ethics in Computing', 3, 2),
('DIT2354', 'DIT2354', 'DIT2354', 'Integrated Systems Project', 4, 2),
('DIT3116', 'DIT3116', 'DIT3116', 'Industrial Attachment', 6, 2);

-- Insert some sample subjects for other programmes
INSERT INTO subjects (code, new_code, legacy_code, name, credit_hours, programme_id) VALUES 
-- DCS subjects (Diploma in Computer Science) - Updated comprehensive list
('DCS1113', 'DCS1113', 'DCS1113', 'Introduction to Computer Science', 3, 1),
('DCS1123', 'DCS1123', 'DCS1123', 'Programming Fundamentals', 3, 1),
('DCS1133', 'DCS1133', 'DCS1133', 'Discrete Mathematics', 3, 1),
('DCS1143', 'DCS1143', 'DCS1143', 'Computer Organization', 3, 1),
('DCS1213', 'DCS1213', 'DCS1213', 'Data Structures', 3, 1),
('DCS1223', 'DCS1223', 'DCS1223', 'Algorithm Analysis', 3, 1),
('DCS1233', 'DCS1233', 'DCS1233', 'Database Systems', 3, 1),
('DCS1243', 'DCS1243', 'DCS1243', 'Software Engineering', 3, 1),
('DCS1313', 'DCS1313', 'DCS1313', 'Operating Systems', 3, 1),
('DCS1323', 'DCS1323', 'DCS1323', 'Computer Networks', 3, 1),
('DCS1333', 'DCS1333', 'DCS1333', 'Web Technologies', 3, 1),
('DCS1343', 'DCS1343', 'DCS1343', 'Object-Oriented Programming', 3, 1),
('DCS2113', 'DCS2113', 'DCS2113', 'Advanced Data Structures', 3, 1),
('DCS2123', 'DCS2123', 'DCS2123', 'Computer Graphics', 3, 1),
('DCS2133', 'DCS2133', 'DCS2133', 'Artificial Intelligence', 3, 1),
('DCS2143', 'DCS2143', 'DCS2143', 'Machine Learning', 3, 1),
('DCS2213', 'DCS2213', 'DCS2213', 'Distributed Systems', 3, 1),
('DCS2223', 'DCS2223', 'DCS2223', 'Cybersecurity', 3, 1),
('DCS2233', 'DCS2233', 'DCS2233', 'Mobile Computing', 3, 1),
('DCS2243', 'DCS2243', 'DCS2243', 'Software Project Management', 3, 1),
('DCS2313', 'DCS2313', 'DCS2313', 'System Design', 3, 1),
('DCS2323', 'DCS2323', 'DCS2323', 'Database Administration', 3, 1),
('DCS2333', 'DCS2333', 'DCS2333', 'Network Administration', 3, 1),
('DCS2343', 'DCS2343', 'DCS2343', 'Final Year Project', 4, 1),
('DCS3116', 'DCS3116', 'DCS3116', 'Industrial Attachment', 6, 1),
-- DCS MPU subjects
('MPU2183', 'MPU2183', 'MPU2183', 'Penghayatan Etika dan Peradaban', 3, 1),
('MPU2133', 'MPU2133', 'MPU2133', 'Bahasa Melayu Komunikasi 1', 3, 1),
('MPU2243', 'MPU2243', 'MPU2243', 'Growth Mindset', 3, 1),
('MPU2213', 'MPU2213', 'MPU2213', 'Bahasa Kebangsaan A', 3, 1),
('MPU2432', 'MPU2432', 'MPU2432', 'Co-curriculum: Sustainability Thinking', 2, 1),
('MPU2373', 'MPU2373', 'MPU2373', 'Integrity and Anti-Corruption', 3, 1),

-- BIT subjects (Bachelor of Information Technology)
('BIT1113', 'BIT1113', 'BIT1113', 'Introduction to Information Technology', 3, 6),
('BIT1123', 'BIT1123', 'BIT1123', 'Programming Fundamentals', 3, 6),
('BIT1133', 'BIT1133', 'BIT1133', 'Database Fundamentals', 3, 6),
('BIT1143', 'BIT1143', 'BIT1143', 'Computer Networks', 3, 6),
('BIT1213', 'BIT1213', 'BIT1213', 'Web Development', 3, 6),
('BIT1223', 'BIT1223', 'BIT1223', 'Data Structures and Algorithms', 3, 6),
('BIT1233', 'BIT1233', 'BIT1233', 'Software Engineering Principles', 3, 6),
('BIT1243', 'BIT1243', 'BIT1243', 'System Analysis and Design', 3, 6),
('BIT1313', 'BIT1313', 'BIT1313', 'Operating Systems', 3, 6),
('BIT1323', 'BIT1323', 'BIT1323', 'Mobile Application Development', 3, 6),
('BIT1333', 'BIT1333', 'BIT1333', 'Human Computer Interaction', 3, 6),
('BIT1343', 'BIT1343', 'BIT1343', 'Project Management', 3, 6),
('BIT2113', 'BIT2113', 'BIT2113', 'Advanced Programming', 3, 6),
('BIT2123', 'BIT2123', 'BIT2123', 'Database Administration', 3, 6),
('BIT2133', 'BIT2133', 'BIT2133', 'Network Security', 3, 6),
('BIT2143', 'BIT2143', 'BIT2143', 'Cloud Computing', 3, 6),
('BIT2213', 'BIT2213', 'BIT2213', 'Artificial Intelligence', 3, 6),
('BIT2223', 'BIT2223', 'BIT2223', 'Machine Learning', 3, 6),
('BIT2233', 'BIT2233', 'BIT2233', 'Data Analytics', 3, 6),
('BIT2243', 'BIT2243', 'BIT2243', 'Software Testing', 3, 6),
('BIT2313', 'BIT2313', 'BIT2313', 'Enterprise Systems', 3, 6),
('BIT2323', 'BIT2323', 'BIT2323', 'IT Governance', 3, 6),
('BIT2333', 'BIT2333', 'BIT2333', 'Research Methods', 3, 6),
('BIT2343', 'BIT2343', 'BIT2343', 'Capstone Project', 4, 6),
('BIT3116', 'BIT3116', 'BIT3116', 'Industrial Training', 6, 6),
-- BIT MPU subjects
('MPU2183', 'MPU2183', 'MPU2183', 'Penghayatan Etika dan Peradaban', 3, 6),
('MPU2133', 'MPU2133', 'MPU2133', 'Bahasa Melayu Komunikasi 1', 3, 6),
('MPU2243', 'MPU2243', 'MPU2243', 'Growth Mindset', 3, 6),
('MPU2213', 'MPU2213', 'MPU2213', 'Bahasa Kebangsaan A', 3, 6),
('MPU2432', 'MPU2432', 'MPU2432', 'Co-curriculum: Sustainability Thinking', 2, 6),
('MPU2373', 'MPU2373', 'MPU2373', 'Integrity and Anti-Corruption', 3, 6),

-- UHAI subjects (University of Hertfordshire Artificial Intelligence)
('4COM2002', '4COM2002', '4COM2002', 'Introduction to Programming and Discrete Structures', 3, 7),
('4COM2004', '4COM2004', '4COM2004', 'Data Modelling for Databases', 3, 7),
('4COM2006', '4COM2006', '4COM2006', 'Team Software Project', 3, 7),
('MPU3193', 'MPU3193', 'MPU3193', 'Philosophy and Current Issues (L&I)', 3, 7),
('MPU3183', 'MPU3183', 'MPU3183', 'Penghayatan Etika dan Peradaban (L)', 3, 7),
('MPU3143', 'MPU3143', 'MPU3143', 'Bahasa Melayu Komunikasi 2 (I)', 3, 7),
('4COM2005', '4COM2005', '4COM2005', 'Computational Problem Solving', 3, 7),
('4COM2003', '4COM2003', '4COM2003', 'From Silicon to C', 3, 7),
('5COM2007', '5COM2007', '5COM2007', 'Principles and Practices of Large Scale Programming', 3, 7),
('5COM2002', '5COM2002', '5COM2002', 'Accessibility and Usability', 3, 7),
('5COM2005', '5COM2005', '5COM2005', 'Database Systems', 3, 7),
('MPU3223', 'MPU3223', 'MPU3223', 'Effective Listening', 3, 7),
('MPU3213', 'MPU3213', 'MPU3213', 'Bahasa Kebangsaan A', 3, 7),
('MPU3373', 'MPU3373', 'MPU3373', 'Integrity and Anti-Corruption', 3, 7),
('5BUS2254', '5BUS2254', '5BUS2254', 'Technopreneurship', 3, 7),
('MPU3432', 'MPU3432', 'MPU3432', 'Co-Curriculum Sustainability Thinking', 2, 7),
('5COM1054', '5COM1054', '5COM1054', 'Algorithms and Data Structures', 3, 7),
('5COM2003', '5COM2003', '5COM2003', 'Artificial Intelligence', 3, 7),
('5COM2004', '5COM2004', '5COM2004', 'Computing Things', 3, 7),
('5COM1055', '5COM1055', '5COM1055', 'Operating Systems and Networks', 3, 7),
('6COM2017', '6COM2017', '6COM2017', 'Artificial Intelligence Project (Part 1)', 4, 7),
('6COM2013', '6COM2013', '6COM2013', 'Software Architecture', 3, 7),
('6COM2000', '6COM2000', '6COM2000', 'Advanced Artificial Intelligence', 3, 7),
('6COM2012', '6COM2012', '6COM2012', 'Social and Collective Artificial Intelligence', 3, 7),
('6COM3601', '6COM3601', '6COM3601', 'Industrial Training', 6, 7),
('6COM2017B', '6COM2017B', '6COM2017B', 'Artificial Intelligence Project (Part 2)', 4, 7),
('6COM2010', '6COM2010', '6COM2010', 'Responsible Computing', 3, 7),
('6COM2007', '6COM2007', '6COM2007', 'Intelligent Adaptive Systems', 3, 7),
('6COM1044', '6COM1044', '6COM1044', 'Machine Learning and Neural Computing', 3, 7),
('6COM2011', '6COM2011', '6COM2011', 'Robotics', 3, 7),

-- UHCS subjects (University of Hertfordshire Cyber Security)
-- New curriculum subjects
('4COM2002', '4COM2002', '4COM2020', 'Introduction to Programming and Discrete Structures', 3, 8),
('4COM2004', '4COM2004', '4COM2004', 'Data Modelling for Databases', 3, 8),
('4COM2006', '4COM2006', '4COM2006', 'Team Software Project', 3, 8),
('MPU3193', 'MPU3193', 'MPU3193', 'Philosophy and Current Issues (L&I)', 3, 8),
('MPU3183', 'MPU3183', 'MPU3183', 'Penghayatan Etika dan Peradaban (L)', 3, 8),
('MPU3143', 'MPU3143', 'MPU3143', 'Bahasa Melayu Komunikasi 2 (I)', 3, 8),
('4COM2005', '4COM2005', '4COM2005', 'Computational Problem Solving', 3, 8),
('4COM2003', '4COM2003', '4COM2003', 'From Silicon to C', 3, 8),
('5COM2007', '5COM2007', '5COM2007', 'Principles and Practices of Large Scale Programming', 3, 8),
('5COM2002', '5COM2002', '5COM2002', 'Accessibility and Usability', 3, 8),
('5COM2005', '5COM2005', '5COM2005', 'Database Systems', 3, 8),
('MPU3223', 'MPU3223', 'MPU3223', 'Effective Listening', 3, 8),
('MPU3213', 'MPU3213', 'MPU3213', 'Bahasa Kebangsaan A', 3, 8),
('MPU3373', 'MPU3373', 'MPU3373', 'Integrity and Anti-Corruption', 3, 8),
('5BUS2254', '5BUS2254', '5BUS2254', 'Technopreneurship', 3, 8),
('MPU3432', 'MPU3432', 'MPU3432', 'Co-Curriculum Sustainability Thinking', 2, 8),
('5COM1054', '5COM1054', '5COM1054', 'Algorithms and Data Structures', 3, 8),
('5COM2003', '5COM2003', '5COM2003', 'Artificial Intelligence', 3, 8),
('5COM2004', '5COM2004', '5COM2004', 'Computing Things', 3, 8),
('5COM1055', '5COM1055', '5COM1055', 'Operating Systems and Networks', 3, 8),
('6COM2019', '6COM2019', '6COM2019', 'Cyber Security and Networks Projects (Part 1)', 4, 8),
('6COM2013', '6COM2013', '6COM2013', 'Software Architecture', 3, 8),
('6COM1040', '6COM1040', '6COM1040', 'Cyber Security', 3, 8),
('6COM2006', '6COM2006', '6COM2006', 'Incident Response Digital Forensics', 3, 8),
('6COM3601', '6COM3601', '6COM3601', 'Industrial Training', 6, 8),
('6COM2019B', '6COM2019B', '6COM2019B', 'Cyber Security and Networks Projects (Part 2)', 4, 8),
('6COM2010', '6COM2010', '6COM2010', 'Responsible Computing', 3, 8),
('6COM1039', '6COM1039', '6COM1039', 'Network Protocols and Architectures', 3, 8),
('6COM1050', '6COM1050', '6COM1050', 'Information Security Management', 3, 8),
('6COM2011', '6COM2011', '6COM2011', 'Robotics', 3, 8),

-- CIT subjects (Certificate in Information Technology)
-- New curriculum subjects
('CIT1123', 'CIT1123', 'CIT1123', 'Statistics and Probability', 3, 3),
('CIT1124', 'CIT1124', 'CIT1124', 'Programming Fundamentals', 4, 3),
('CIT1133', 'CIT1133', 'CIT1133', 'Database Fundamentals', 3, 3),
('CIT1143', 'CIT1143', 'CIT1143', 'Data Communication and Networking', 3, 3),
('CIT1213', 'CIT1213', 'CIT1213', 'Internet of Things', 3, 3),
('CIT1223', 'CIT1223', 'CIT1223', 'Calculus and Algebra', 3, 3),
('CIT1233', 'CIT1233', 'CIT1233', 'System Analysis and Design Fundamentals', 3, 3),
('CIT1244', 'CIT1244', 'CIT1244', 'Web and Mobile Systems', 4, 3),
('CIT1313', 'CIT1313', 'CIT1313', 'Operating Systems', 3, 3),
('CIT1324', 'CIT1324', 'CIT1324', 'Cloud Computing', 4, 3),
('CIT1334', 'CIT1334', 'CIT1334', 'Object-Oriented Development', 4, 3),
('CIT1344', 'CIT1344', 'CIT1344', 'Advanced Networking', 4, 3),
('CIT2113', 'CIT2113', 'CIT2113', 'Computer Architecture', 3, 3),
('CIT2124', 'CIT2124', 'CIT2124', 'System Paradigms', 4, 3),
('CIT2133', 'CIT2133', 'CIT2133', 'Python Programming', 3, 3),
('CIT2144', 'CIT2144', 'CIT2144', 'User Experience Design', 4, 3),
('CIT2213', 'CIT2213', 'CIT2213', 'Project Management', 3, 3),
('CIT2214', 'CIT2214', 'CIT2214', 'Discrete Mathematics', 4, 3),
('CIT2234', 'CIT2234', 'CIT2234', 'Cybersecurity Fundamentals', 4, 3),
('CIT2243', 'CIT2243', 'CIT2243', 'Ethics in Computing', 3, 3),
('CIT2354', 'CIT2354', 'CIT2354', 'Integrated Systems Project', 4, 3),
('CIT3116', 'CIT3116', 'CIT3116', 'Industrial Attachment', 6, 3),
-- Legacy curriculum additional subjects
('CIT1113', 'CIT1113', 'CIT1113', 'Introduction to Information Technology', 3, 3),
('CIT1253', 'CIT1253', 'CIT1253', 'Computer Organization', 3, 3),
('CIT1263', 'CIT1263', 'CIT1263', 'Discrete Mathematics', 3, 3),
('CIT1353', 'CIT1353', 'CIT1353', 'Human Computer Interaction', 3, 3),
('CIT2153', 'CIT2153', 'CIT2153', 'Database Application Development', 3, 3),
('CIT2253', 'CIT2253', 'CIT2253', 'Computer Graphics', 3, 3),
('CIT2263', 'CIT2263', 'CIT2263', 'Software Engineering Principles', 3, 3),
('CIT2273', 'CIT2273', 'CIT2273', 'Data Science Fundamentals', 3, 3),
('CIT2283', 'CIT2283', 'CIT2283', 'Artificial Intelligence Fundamentals', 3, 3),
('CIT2293', 'CIT2293', 'CIT2293', 'Machine Learning', 3, 3),
-- MPU subjects for CIT programme
('MPU2183', 'MPU2183', 'MPU2183', 'Penghayatan Etika dan Peradaban', 3, 3),
('MPU2133', 'MPU2133', 'MPU2133', 'Bahasa Melayu Komunikasi 1', 3, 3),
('MPU2243', 'MPU2243', 'MPU2243', 'Growth Mindset', 3, 3),
('MPU2213', 'MPU2213', 'MPU2213', 'Bahasa Kebangsaan A', 3, 3),
('MPU2432', 'MPU2432', 'MPU2432', 'Co-curriculum: Sustainability Thinking', 2, 3),
('MPU2373', 'MPU2373', 'MPU2373', 'Integrity and Anti-Corruption', 3, 3),

-- BCS subjects
('BCS101', 'Advanced Software Engineering', 3, 4),
('BCS102', 'Computer Architecture and Organization', 3, 4),
('BCS103', 'Advanced Networking and Security', 3, 4),
('BCS104', 'Artificial Intelligence Fundamentals', 3, 4),
('BCS201', 'Machine Learning', 3, 4),
('BCS202', 'Data Mining and Analytics', 3, 4),

-- FIIT subjects (Foundation in Information Technology)
('FIIT1114', 'FIIT1114', 'FIIT1114', 'Basic Mathematics', 3, 5),
('FIIT1124', 'FIIT1124', 'FIIT1124', 'Fundamentals of Information Technology', 3, 5),
('FIIT1133', 'FIIT1133', 'FIIT1133', 'English Communication', 3, 5),
('FIIT1143', 'FIIT1143', 'FIIT1143', 'Personal and Professional Development', 3, 5),
('FIIT1154', 'FIIT1154', 'FIIT1154', 'Programming Methodology', 3, 5),
('FIIT1213', 'FIIT1213', 'FIIT1213', 'Computer Fundamentals', 3, 5),
('FIIT1223', 'FIIT1223', 'FIIT1223', 'Introduction to Programming', 3, 5),
('FIIT1233', 'FIIT1233', 'FIIT1233', 'Study Skills and Academic Writing', 3, 5),
('FIIT1243', 'FIIT1243', 'FIIT1243', 'Digital Literacy', 3, 5),
('FIIT1253', 'FIIT1253', 'FIIT1253', 'Basic Statistics', 3, 5),
-- MPU subjects for FIIT programme
('MPU2183', 'MPU2183', 'MPU2183', 'Penghayatan Etika dan Peradaban', 3, 5),
('MPU2133', 'MPU2133', 'MPU2133', 'Bahasa Melayu Komunikasi 1', 3, 5),
('MPU2243', 'MPU2243', 'MPU2243', 'Growth Mindset', 3, 5),
('MPU2213', 'MPU2213', 'MPU2213', 'Bahasa Kebangsaan A', 3, 5),
('MPU2432', 'MPU2432', 'MPU2432', 'Co-curriculum: Sustainability Thinking', 2, 5);

COMMIT;