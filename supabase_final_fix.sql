-- ============================================
-- الحل النهائي: تصحيح RLS + ملء البيانات
-- ============================================

-- 1. تعطيل RLS مؤقتاً لإدراج البيانات
ALTER TABLE public.assignments DISABLE ROW LEVEL SECURITY;

-- 2. حذف التعيينات القديمة
DELETE FROM public.assignments;

-- 3. ملء assignments بشكل صحيح
-- كل دكتور يُسند إلى المواد الخاصة به
INSERT INTO public.assignments (user_id, course_id, scope, role)
VALUES 
  -- هذه معرّفات حقيقية من قاعدة البيانات
  -- Dr. Ahmed Mahmoud - CCS209, CCS302
  ((SELECT id FROM public.users WHERE university_id = 'prof_001' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS209' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_001' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS302' LIMIT 1),
   'course', 'doctor'),

  -- Dr. Fatima Ibrahim - CCS100, CCS101
  ((SELECT id FROM public.users WHERE university_id = 'prof_002' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CYS300' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_002' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS209' LIMIT 1),
   'course', 'doctor'),

  -- Add more as needed
  ((SELECT id FROM public.users WHERE university_id = 'prof_003' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CYS302' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_004' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS303' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_005' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS302' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_006' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CYS300' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_007' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS302' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_008' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CYS302' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_009' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS303' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_010' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CCS209' LIMIT 1),
   'course', 'doctor'),
   
  ((SELECT id FROM public.users WHERE university_id = 'prof_011' AND role = 'doctor' LIMIT 1),
   (SELECT id FROM public.courses WHERE code = 'CYS302' LIMIT 1),
   'course', 'doctor');

-- 4. تفعيل RLS مجدداً
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;

-- 5. التحقق من النتائج
SELECT COUNT(*) as total_assignments FROM public.assignments;
SELECT a.id, 
       u.full_name as doctor_name, 
       c.code as course_code,
       a.role
FROM public.assignments a
JOIN public.users u ON a.user_id = u.id
JOIN public.courses c ON a.course_id = c.id
ORDER BY c.code;
