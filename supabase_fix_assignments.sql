-- ==============================================
-- حل جزري: ملء جدول assignments من بيانات الدكاترة
-- ==============================================

-- 1. حذف البيانات القديمة (إذا كانت موجودة)
DELETE FROM public.assignments;

-- 2. ملء assignments من بيانات الدكاترة والمواد
-- نفترض أن هناك دكاترة مسجلين في النظام
INSERT INTO public.assignments (user_id, course_id, scope, role)
SELECT 
  u.id as user_id,
  c.id as course_id,
  'course' as scope,
  'doctor' as role
FROM 
  public.users u,
  public.courses c
WHERE 
  u.role = 'doctor'
  AND NOT EXISTS (
    -- تجنب التكرار إذا كانت هناك تعيينات بالفعل
    SELECT 1 FROM public.assignments a 
    WHERE a.user_id = u.id AND a.course_id = c.id AND a.role = 'doctor'
  )
LIMIT 20;  -- حد أقصى 20 تعيين في البداية

-- 3. التحقق من النتائج
SELECT 'Assignments created' as status, COUNT(*) as count FROM public.assignments;
SELECT course_id, user_id, role FROM public.assignments ORDER BY created_at DESC LIMIT 10;
