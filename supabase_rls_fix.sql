-- ============================================
-- إصلاح RLS Policies للـ assignments
-- ============================================

-- 1. حذف الـ policy القديم (إن وجد)
DROP POLICY IF EXISTS "Assignments: read all" ON public.assignments;

-- 2. إنشاء policy جديد - اسمح للجميع بالقراءة
CREATE POLICY "Assignments readable by all" 
  ON public.assignments 
  FOR SELECT 
  USING (true);

-- 3. اسمح للـ service role بالإدراج والتحديث والحذف
CREATE POLICY "Assignments insert for service"
  ON public.assignments
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Assignments update for service"
  ON public.assignments
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Assignments delete for service"
  ON public.assignments
  FOR DELETE
  USING (true);

-- 4. التحقق من النتائج
SELECT * FROM public.assignments LIMIT 5;
