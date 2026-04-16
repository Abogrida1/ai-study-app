const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

const outputDir = path.join(__dirname, '..', 'test_data');
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

// ============================================
// 1. courses.xlsx — Real Cyber Security Program
// Zagazig University - Faculty of Computers and Informatics
// ============================================
const coursesData = [
  // ===== LEVEL 1 — SEMESTER 1 =====
  { code: 'CCS100', name: 'Computer Science Fundamentals', name_ar: 'أساسيات علوم الحاسب', credit_hours: 3, level: 1, semester: 1, has_sections: 'yes' },
  { code: 'CCS101', name: 'Computer Programming I', name_ar: 'برمجة حاسب 1', credit_hours: 3, level: 1, semester: 1, has_sections: 'yes' },
  { code: 'CBS100', name: 'Mathematics I', name_ar: 'رياضيات 1', credit_hours: 3, level: 1, semester: 1, has_sections: 'yes' },
  { code: 'CBS102', name: 'Electronics', name_ar: 'إلكترونيات', credit_hours: 3, level: 1, semester: 1, has_sections: 'yes' },
  { code: 'CBS103', name: 'Probability and Statistics', name_ar: 'احتمالات وإحصاء', credit_hours: 3, level: 1, semester: 1, has_sections: 'yes' },
  { code: 'CHU100', name: 'English', name_ar: 'لغة إنجليزية', credit_hours: 2, level: 1, semester: 1, has_sections: 'no' },

  // ===== LEVEL 1 — SEMESTER 2 =====
  { code: 'CHU101', name: 'Report Writing and Presentation Skills', name_ar: 'كتابة التقارير ومهارات العرض', credit_hours: 2, level: 1, semester: 2, has_sections: 'no' },
  { code: 'CBS101', name: 'Mathematics II', name_ar: 'رياضيات 2', credit_hours: 3, level: 1, semester: 2, has_sections: 'yes' },
  { code: 'CCS102', name: 'Computer Programming II', name_ar: 'برمجة حاسب 2', credit_hours: 3, level: 1, semester: 2, has_sections: 'yes' },
  { code: 'CHU200', name: 'Social Issues', name_ar: 'قضايا مجتمع', credit_hours: 2, level: 1, semester: 2, has_sections: 'no' },
  { code: 'CBS106', name: 'Discrete Structures', name_ar: 'بنيات منفصلة', credit_hours: 3, level: 1, semester: 2, has_sections: 'yes' },
  { code: 'CBS104', name: 'Data Communication', name_ar: 'اتصالات بيانات', credit_hours: 3, level: 1, semester: 2, has_sections: 'yes' },

  // ===== LEVEL 2 — SEMESTER 1 =====
  { code: 'CCS200', name: 'Algorithms and Data Structures', name_ar: 'خوارزميات وهياكل بيانات', credit_hours: 3, level: 2, semester: 1, has_sections: 'yes' },
  { code: 'CBS105', name: 'Operations Research', name_ar: 'بحوث عمليات', credit_hours: 3, level: 2, semester: 1, has_sections: 'yes' },
  { code: 'CCS204', name: 'Operating Systems', name_ar: 'نظم تشغيل', credit_hours: 3, level: 2, semester: 1, has_sections: 'yes' },
  { code: 'CCS202', name: 'Database Systems', name_ar: 'نظم قواعد بيانات', credit_hours: 3, level: 2, semester: 1, has_sections: 'yes' },
  { code: 'CCS203', name: 'Computer Networks I', name_ar: 'شبكات حاسب 1', credit_hours: 3, level: 2, semester: 1, has_sections: 'yes' },
  { code: 'CBS107', name: 'Digital Logic Design', name_ar: 'تصميم منطق رقمي', credit_hours: 3, level: 2, semester: 1, has_sections: 'yes' },

  // ===== LEVEL 2 — SEMESTER 2 =====
  { code: 'CCS205', name: 'Network and Internet Programming', name_ar: 'برمجة شبكات وإنترنت', credit_hours: 3, level: 2, semester: 2, has_sections: 'yes' },
  { code: 'CCS206', name: 'Internet of Things', name_ar: 'إنترنت الأشياء', credit_hours: 3, level: 2, semester: 2, has_sections: 'yes' },
  { code: 'CYS200', name: 'Fundamentals of Cyber Security', name_ar: 'أساسيات الأمن السيبراني', credit_hours: 3, level: 2, semester: 2, has_sections: 'yes' },
  { code: 'CCS208', name: 'Artificial Intelligence', name_ar: 'ذكاء اصطناعي', credit_hours: 3, level: 2, semester: 2, has_sections: 'yes' },
  { code: 'CCS201', name: 'Computer Organization and Architecture', name_ar: 'تنظيم وبنية الحاسب', credit_hours: 3, level: 2, semester: 2, has_sections: 'yes' },

  // ===== LEVEL 3 — SEMESTER 1 =====
  { code: 'CYS300', name: 'Introduction to Cryptography', name_ar: 'مقدمة في التشفير', credit_hours: 3, level: 3, semester: 1, has_sections: 'yes' },
  { code: 'CCS209', name: 'Software Engineering', name_ar: 'هندسة برمجيات', credit_hours: 3, level: 3, semester: 1, has_sections: 'yes' },
  { code: 'CYS302', name: 'Digital Forensics and Investigations', name_ar: 'الأدلة الرقمية والتحقيقات', credit_hours: 3, level: 3, semester: 1, has_sections: 'yes' },
  { code: 'CCS303', name: 'Mobile Application Development', name_ar: 'تطوير تطبيقات الموبايل', credit_hours: 3, level: 3, semester: 1, has_sections: 'yes' },
  { code: 'CCS302', name: 'Computer Networks II', name_ar: 'شبكات حاسب 2', credit_hours: 3, level: 3, semester: 1, has_sections: 'yes' },

  // ===== LEVEL 3 — SEMESTER 2 =====
  { code: 'CCS207', name: 'Multimedia', name_ar: 'وسائط متعددة', credit_hours: 3, level: 3, semester: 2, has_sections: 'yes' },
  { code: 'CYS301', name: 'Network Security', name_ar: 'أمن الشبكات', credit_hours: 3, level: 3, semester: 2, has_sections: 'yes' },
  { code: 'CCS301', name: 'Machine Learning', name_ar: 'تعلم الآلة', credit_hours: 3, level: 3, semester: 2, has_sections: 'yes' },
  { code: 'CYS303', name: 'Penetration Testing', name_ar: 'اختبار الاختراق', credit_hours: 3, level: 3, semester: 2, has_sections: 'yes' },
  { code: 'CYS304', name: 'Secure Software Development', name_ar: 'تطوير برمجيات آمنة', credit_hours: 3, level: 3, semester: 2, has_sections: 'yes' },

  // ===== LEVEL 4 — SEMESTER 1 =====
  { code: 'CYS402', name: 'Advanced Penetration Testing', name_ar: 'اختبار اختراق متقدم', credit_hours: 3, level: 4, semester: 1, has_sections: 'yes' },
  { code: 'CYS403', name: 'Machine Learning for Cyber Security', name_ar: 'تعلم الآلة للأمن السيبراني', credit_hours: 3, level: 4, semester: 1, has_sections: 'yes' },
  { code: 'CYS401', name: 'Malware Analysis', name_ar: 'تحليل البرمجيات الخبيثة', credit_hours: 3, level: 4, semester: 1, has_sections: 'yes' },
  { code: 'CYS400', name: 'Multimedia Security', name_ar: 'أمن الوسائط المتعددة', credit_hours: 3, level: 4, semester: 1, has_sections: 'yes' },
  { code: 'PRJ401', name: 'Project', name_ar: 'مشروع', credit_hours: 3, level: 4, semester: 1, has_sections: 'no' },

  // ===== LEVEL 4 — SEMESTER 2 =====
  { code: 'CYS405', name: 'Mobile Devices Forensics', name_ar: 'أدلة رقمية للأجهزة المحمولة', credit_hours: 3, level: 4, semester: 2, has_sections: 'yes' },
  { code: 'CYS404', name: 'Exploit Development for Penetration Testers', name_ar: 'تطوير استغلال لمختبري الاختراق', credit_hours: 3, level: 4, semester: 2, has_sections: 'yes' },
  { code: 'PRJ402', name: 'Project', name_ar: 'مشروع التخرج', credit_hours: 3, level: 4, semester: 2, has_sections: 'no' },
];

const coursesWB = XLSX.utils.book_new();
const coursesWS = XLSX.utils.json_to_sheet(coursesData);
XLSX.utils.book_append_sheet(coursesWB, coursesWS, 'courses');
XLSX.writeFile(coursesWB, path.join(outputDir, 'courses.xlsx'));
console.log('✅ courses.xlsx — ' + coursesData.length + ' courses');

// ============================================
// 2. students.xlsx — Sample students
// ============================================
const studentsData = [
  // Level 1, Section 1
  { university_id: '2024001', password: 'Student@01', full_name: 'أحمد محمد علي', level: 1, section: 1, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024002', password: 'Student@02', full_name: 'سارة أحمد حسن', level: 1, section: 1, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024003', password: 'Student@03', full_name: 'ياسمين عمر فاروق', level: 1, section: 1, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024004', password: 'Student@04', full_name: 'عمرو حسام إبراهيم', level: 1, section: 1, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024005', password: 'Student@05', full_name: 'نورهان خالد سعيد', level: 1, section: 1, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  // Level 1, Section 2
  { university_id: '2024006', password: 'Student@06', full_name: 'محمد خالد سعيد', level: 1, section: 2, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024007', password: 'Student@07', full_name: 'فاطمة علي محمود', level: 1, section: 2, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024008', password: 'Student@08', full_name: 'كريم مصطفى أحمد', level: 1, section: 2, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024009', password: 'Student@09', full_name: 'مريم حسن عبدالله', level: 1, section: 2, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  { university_id: '2024010', password: 'Student@10', full_name: 'يوسف سامي عادل', level: 1, section: 2, courses: 'CCS100,CCS101,CBS100,CBS102,CBS103,CHU100' },
  // Level 2, Section 1
  { university_id: '2023001', password: 'Student@11', full_name: 'مروان حسام الدين', level: 2, section: 1, courses: 'CCS200,CBS105,CCS204,CCS202,CCS203,CBS107' },
  { university_id: '2023002', password: 'Student@12', full_name: 'رنا محمد عبدالعزيز', level: 2, section: 1, courses: 'CCS200,CBS105,CCS204,CCS202,CCS203,CBS107' },
  { university_id: '2023003', password: 'Student@13', full_name: 'أمير وليد حسن', level: 2, section: 1, courses: 'CCS200,CBS105,CCS204,CCS202,CCS203,CBS107' },
  // Level 2, Section 2
  { university_id: '2023004', password: 'Student@14', full_name: 'ليلى سمير أحمد', level: 2, section: 2, courses: 'CCS200,CBS105,CCS204,CCS202,CCS203,CBS107' },
  { university_id: '2023005', password: 'Student@15', full_name: 'خالد عصام محمد', level: 2, section: 2, courses: 'CCS200,CBS105,CCS204,CCS202,CCS203,CBS107' },
  // Level 3, Section 1
  { university_id: '2022001', password: 'Student@16', full_name: 'عبدالرحمن طارق حسين', level: 3, section: 1, courses: 'CYS300,CCS209,CYS302,CCS303,CCS302' },
  { university_id: '2022002', password: 'Student@17', full_name: 'هدى رمضان حسين', level: 3, section: 1, courses: 'CYS300,CCS209,CYS302,CCS303,CCS302' },
  // Level 3, Section 2
  { university_id: '2022003', password: 'Student@18', full_name: 'عمر فاروق أشرف', level: 3, section: 2, courses: 'CYS300,CCS209,CYS302,CCS303,CCS302' },
  { university_id: '2022004', password: 'Student@19', full_name: 'دينا ماجد حسين', level: 3, section: 2, courses: 'CYS300,CCS209,CYS302,CCS303,CCS302' },
];

const studentsWB = XLSX.utils.book_new();
const studentsWS = XLSX.utils.json_to_sheet(studentsData);
XLSX.utils.book_append_sheet(studentsWB, studentsWS, 'students');
XLSX.writeFile(studentsWB, path.join(outputDir, 'students.xlsx'));
console.log('✅ students.xlsx — ' + studentsData.length + ' students');

// ============================================
// 3. doctors.xlsx
// ============================================
const doctorsData = [
  { university_id: 'prof_001', password: 'Doctor@01', full_name: 'د. أحمد سعيد محمود', course_codes: 'CCS100,CCS200' },
  { university_id: 'prof_002', password: 'Doctor@02', full_name: 'د. منى إبراهيم حسن', course_codes: 'CBS100,CBS101' },
  { university_id: 'prof_003', password: 'Doctor@03', full_name: 'د. سامي محمود عبدالله', course_codes: 'CBS102,CBS107' },
  { university_id: 'prof_004', password: 'Doctor@04', full_name: 'د. هالة عبدالرحمن', course_codes: 'CCS101,CCS102' },
  { university_id: 'prof_005', password: 'Doctor@05', full_name: 'د. محمد عاطف سليمان', course_codes: 'CBS103,CBS105' },
  { university_id: 'prof_006', password: 'Doctor@06', full_name: 'د. إيمان رشدي أحمد', course_codes: 'CCS202,CCS204' },
  { university_id: 'prof_007', password: 'Doctor@07', full_name: 'د. خالد حسني عبدالعال', course_codes: 'CCS203,CCS302' },
  { university_id: 'prof_008', password: 'Doctor@08', full_name: 'د. نادية فؤاد حسن', course_codes: 'CYS200,CYS300' },
  { university_id: 'prof_009', password: 'Doctor@09', full_name: 'د. أسامة رضا محمد', course_codes: 'CCS208,CCS301' },
  { university_id: 'prof_010', password: 'Doctor@10', full_name: 'د. سمير جودة عبدالله', course_codes: 'CCS209,CCS303' },
  { university_id: 'prof_011', password: 'Doctor@11', full_name: 'د. ريهام عادل فتحي', course_codes: 'CYS302,CYS303' },
  { university_id: 'prof_012', password: 'Doctor@12', full_name: 'د. طارق محمود أحمد', course_codes: 'CBS104,CBS106' },
  { university_id: 'prof_013', password: 'Doctor@13', full_name: 'د. عماد الدين حسن', course_codes: 'CCS205,CCS206' },
  { university_id: 'prof_014', password: 'Doctor@14', full_name: 'د. فاطمة الزهراء علي', course_codes: 'CCS201,CCS207' },
  { university_id: 'prof_015', password: 'Doctor@15', full_name: 'د. حسام الدين عبدالرحيم', course_codes: 'CYS301,CYS304' },
  { university_id: 'prof_016', password: 'Doctor@16', full_name: 'د. عبير محمد سالم', course_codes: 'CYS400,CYS401' },
  { university_id: 'prof_017', password: 'Doctor@17', full_name: 'د. محمود رشاد أحمد', course_codes: 'CYS402,CYS403' },
  { university_id: 'prof_018', password: 'Doctor@18', full_name: 'د. سعاد حسين محمد', course_codes: 'CYS404,CYS405' },
  { university_id: 'prof_019', password: 'Doctor@19', full_name: 'د. ممدوح حكيم عبدالله', course_codes: 'CHU100,CHU101,CHU200' },
];

const doctorsWB = XLSX.utils.book_new();
const doctorsWS = XLSX.utils.json_to_sheet(doctorsData);
XLSX.utils.book_append_sheet(doctorsWB, doctorsWS, 'doctors');
XLSX.writeFile(doctorsWB, path.join(outputDir, 'doctors.xlsx'));
console.log('✅ doctors.xlsx — ' + doctorsData.length + ' doctors');

// ============================================
// 4. tas.xlsx
// ============================================
const tasData = [
  // Level 1 TAs
  { university_id: 'ta_001', password: 'TAPass@01', full_name: 'م. محمد علي حسن', course_code: 'CCS100', sections: '1,2' },
  { university_id: 'ta_002', password: 'TAPass@02', full_name: 'م. نورا حسين أحمد', course_code: 'CCS101', sections: '1,2' },
  { university_id: 'ta_003', password: 'TAPass@03', full_name: 'م. أيمن خالد سعد', course_code: 'CBS100', sections: '1,2' },
  { university_id: 'ta_004', password: 'TAPass@04', full_name: 'م. سلمى رشاد محمد', course_code: 'CBS102', sections: '1,2' },
  { university_id: 'ta_005', password: 'TAPass@05', full_name: 'م. أحمد رياض إبراهيم', course_code: 'CBS103', sections: '1,2' },
  { university_id: 'ta_003', password: 'TAPass@03', full_name: 'م. أيمن خالد سعد', course_code: 'CBS101', sections: '1,2' },
  { university_id: 'ta_002', password: 'TAPass@02', full_name: 'م. نورا حسين أحمد', course_code: 'CCS102', sections: '1,2' },
  { university_id: 'ta_004', password: 'TAPass@04', full_name: 'م. سلمى رشاد محمد', course_code: 'CBS106', sections: '1,2' },
  { university_id: 'ta_001', password: 'TAPass@01', full_name: 'م. محمد علي حسن', course_code: 'CBS104', sections: '1,2' },

  // Level 2 TAs
  { university_id: 'ta_006', password: 'TAPass@06', full_name: 'م. عمر فاروق عادل', course_code: 'CCS200', sections: '1,2' },
  { university_id: 'ta_007', password: 'TAPass@07', full_name: 'م. دينا ماجد حسين', course_code: 'CCS204', sections: '1,2' },
  { university_id: 'ta_006', password: 'TAPass@06', full_name: 'م. عمر فاروق عادل', course_code: 'CCS202', sections: '1,2' },
  { university_id: 'ta_007', password: 'TAPass@07', full_name: 'م. دينا ماجد حسين', course_code: 'CCS203', sections: '1,2' },
  { university_id: 'ta_008', password: 'TAPass@08', full_name: 'م. حسام عبدالنبي', course_code: 'CBS105', sections: '1,2' },
  { university_id: 'ta_008', password: 'TAPass@08', full_name: 'م. حسام عبدالنبي', course_code: 'CBS107', sections: '1,2' },
  { university_id: 'ta_006', password: 'TAPass@06', full_name: 'م. عمر فاروق عادل', course_code: 'CCS205', sections: '1,2' },
  { university_id: 'ta_007', password: 'TAPass@07', full_name: 'م. دينا ماجد حسين', course_code: 'CCS206', sections: '1,2' },
  { university_id: 'ta_009', password: 'TAPass@09', full_name: 'م. ريم عبدالحميد', course_code: 'CYS200', sections: '1,2' },
  { university_id: 'ta_009', password: 'TAPass@09', full_name: 'م. ريم عبدالحميد', course_code: 'CCS208', sections: '1,2' },
  { university_id: 'ta_008', password: 'TAPass@08', full_name: 'م. حسام عبدالنبي', course_code: 'CCS201', sections: '1,2' },

  // Level 3 TAs
  { university_id: 'ta_009', password: 'TAPass@09', full_name: 'م. ريم عبدالحميد', course_code: 'CYS300', sections: '1,2' },
  { university_id: 'ta_010', password: 'TAPass@10', full_name: 'م. كريم حسني أحمد', course_code: 'CCS209', sections: '1,2' },
  { university_id: 'ta_010', password: 'TAPass@10', full_name: 'م. كريم حسني أحمد', course_code: 'CYS302', sections: '1,2' },
  { university_id: 'ta_010', password: 'TAPass@10', full_name: 'م. كريم حسني أحمد', course_code: 'CCS303', sections: '1,2' },
  { university_id: 'ta_009', password: 'TAPass@09', full_name: 'م. ريم عبدالحميد', course_code: 'CCS302', sections: '1,2' },
];

const tasWB = XLSX.utils.book_new();
const tasWS = XLSX.utils.json_to_sheet(tasData);
XLSX.utils.book_append_sheet(tasWB, tasWS, 'tas');
XLSX.writeFile(tasWB, path.join(outputDir, 'tas.xlsx'));
console.log('✅ tas.xlsx — ' + tasData.length + ' TA rows (' + new Set(tasData.map(t => t.university_id)).size + ' unique TAs)');

console.log('\n🎉 All files created in: ' + outputDir);
console.log('\n📋 Summary:');
console.log('   courses.xlsx  — ' + coursesData.length + ' courses (4 levels × 2 semesters)');
console.log('   students.xlsx — ' + studentsData.length + ' students');
console.log('   doctors.xlsx  — ' + doctorsData.length + ' doctors');
console.log('   tas.xlsx      — ' + new Set(tasData.map(t => t.university_id)).size + ' TAs, ' + tasData.length + ' assignments');
