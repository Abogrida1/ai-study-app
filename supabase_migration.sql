-- ============================================================
-- AI STUDY APP — FULL DATABASE MIGRATION
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- PART 1: CORE ACADEMIC STRUCTURE
-- ============================================================

-- 1. USERS (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  university_id TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  email TEXT,
  role TEXT NOT NULL CHECK (role IN ('student', 'doctor', 'ta')),
  avatar_url TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. LEVELS (academic years)
CREATE TABLE IF NOT EXISTS public.levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_ar TEXT,
  "order" INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. GROUPS (within a level)
CREATE TABLE IF NOT EXISTS public.groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level_id UUID NOT NULL REFERENCES public.levels(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_ar TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. SECTIONS (within a group)
CREATE TABLE IF NOT EXISTS public.sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_ar TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. COURSES
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  name_ar TEXT,
  description TEXT,
  credit_hours INT DEFAULT 3,
  level_id UUID REFERENCES public.levels(id),
  semester TEXT,
  thumbnail_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. COURSE_PREREQUISITES
CREATE TABLE IF NOT EXISTS public.course_prerequisites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  prerequisite_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  UNIQUE(course_id, prerequisite_id)
);

-- 7. ENROLLMENTS (student ↔ course + section)
CREATE TABLE IF NOT EXISTS public.enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  section_id UUID REFERENCES public.sections(id),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'dropped', 'completed')),
  enrolled_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, course_id)
);

-- 8. ASSIGNMENTS (teaching: doctor/ta → course/group/section)
CREATE TABLE IF NOT EXISTS public.assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  scope TEXT NOT NULL CHECK (scope IN ('course', 'group', 'section')),
  scope_id UUID,
  role TEXT NOT NULL CHECK (role IN ('doctor', 'ta')),
  assigned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, course_id, scope, scope_id)
);

-- 9. LECTURES
CREATE TABLE IF NOT EXISTS public.lectures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  title_ar TEXT,
  description TEXT,
  video_url TEXT,
  pdf_url TEXT,
  "order" INT DEFAULT 0,
  duration_minutes INT,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 10. REQUIREMENTS (assignments/homework)
CREATE TABLE IF NOT EXISTS public.requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT CHECK (type IN ('assignment', 'file', 'link')),
  file_url TEXT,
  link_url TEXT,
  due_date TIMESTAMPTZ,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- PART 2: EXAM SYSTEM
-- ============================================================

-- 11. EXAMS
CREATE TABLE IF NOT EXISTS public.exams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  total_marks NUMERIC DEFAULT 0,
  duration_minutes INT DEFAULT 60,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 12. EXAM_QUESTIONS
CREATE TABLE IF NOT EXISTS public.exam_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL CHECK (question_type IN ('mcq', 'true_false', 'essay')),
  marks NUMERIC DEFAULT 1,
  "order" INT DEFAULT 0,
  correct_answer TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 13. EXAM_OPTIONS (MCQ choices)
CREATE TABLE IF NOT EXISTS public.exam_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES public.exam_questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT false,
  "order" INT DEFAULT 0
);

-- 14. EXAM_ATTEMPTS
CREATE TABLE IF NOT EXISTS public.exam_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ DEFAULT now(),
  submitted_at TIMESTAMPTZ,
  score NUMERIC,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'submitted', 'graded')),
  UNIQUE(exam_id, user_id)
);

-- 15. EXAM_ANSWERS
CREATE TABLE IF NOT EXISTS public.exam_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES public.exam_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES public.exam_questions(id) ON DELETE CASCADE,
  selected_option_id UUID REFERENCES public.exam_options(id),
  answer_text TEXT,
  is_correct BOOLEAN,
  marks_awarded NUMERIC DEFAULT 0
);

-- ============================================================
-- PART 3: CHAT SYSTEM
-- ============================================================

-- 16. CHATS
CREATE TABLE IF NOT EXISTS public.chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('course', 'section', 'direct')),
  name TEXT,
  course_id UUID REFERENCES public.courses(id),
  section_id UUID REFERENCES public.sections(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 17. CHAT_MEMBERS
CREATE TABLE IF NOT EXISTS public.chat_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(chat_id, user_id)
);

-- 18. MESSAGES
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'file', 'image')),
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- PART 4: RLS POLICIES
-- ============================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_prerequisites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lectures ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Service role can manage users" ON public.users
  FOR ALL USING (auth.role() = 'service_role');

-- Academic structure: readable by all authenticated
CREATE POLICY "Authenticated can view levels" ON public.levels
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated can view groups" ON public.groups
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated can view sections" ON public.sections
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated can view courses" ON public.courses
  FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated can view prerequisites" ON public.course_prerequisites
  FOR SELECT USING (auth.role() = 'authenticated');

-- Enrollments: students see their own
CREATE POLICY "Students view own enrollments" ON public.enrollments
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service role manage enrollments" ON public.enrollments
  FOR ALL USING (auth.role() = 'service_role');

-- Assignments: teachers see their own
CREATE POLICY "Teachers view own assignments" ON public.assignments
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Service role manage assignments" ON public.assignments
  FOR ALL USING (auth.role() = 'service_role');

-- Lectures: enrolled students + assigned teachers can view
CREATE POLICY "View lectures for enrolled/assigned" ON public.lectures
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.enrollments e WHERE e.user_id = auth.uid() AND e.course_id = lectures.course_id)
    OR EXISTS (SELECT 1 FROM public.assignments a WHERE a.user_id = auth.uid() AND a.course_id = lectures.course_id)
  );
CREATE POLICY "Teachers manage own lectures" ON public.lectures
  FOR INSERT WITH CHECK (created_by = auth.uid());
CREATE POLICY "Teachers update own lectures" ON public.lectures
  FOR UPDATE USING (created_by = auth.uid());
CREATE POLICY "Teachers delete own lectures" ON public.lectures
  FOR DELETE USING (created_by = auth.uid());

-- Requirements: same as lectures
CREATE POLICY "View requirements for enrolled/assigned" ON public.requirements
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.enrollments e WHERE e.user_id = auth.uid() AND e.course_id = requirements.course_id)
    OR EXISTS (SELECT 1 FROM public.assignments a WHERE a.user_id = auth.uid() AND a.course_id = requirements.course_id)
  );
CREATE POLICY "Teachers manage requirements" ON public.requirements
  FOR INSERT WITH CHECK (created_by = auth.uid());

-- Exams: enrolled students can view published, teachers can manage
CREATE POLICY "View published exams" ON public.exams
  FOR SELECT USING (
    (is_published = true AND EXISTS (SELECT 1 FROM public.enrollments e WHERE e.user_id = auth.uid() AND e.course_id = exams.course_id))
    OR created_by = auth.uid()
  );
CREATE POLICY "Teachers create exams" ON public.exams
  FOR INSERT WITH CHECK (created_by = auth.uid());
CREATE POLICY "Teachers update exams" ON public.exams
  FOR UPDATE USING (created_by = auth.uid());

-- Exam questions: visible if exam is visible
CREATE POLICY "View exam questions" ON public.exam_questions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.exams ex
      WHERE ex.id = exam_questions.exam_id
      AND (
        (ex.is_published = true AND EXISTS (SELECT 1 FROM public.enrollments e WHERE e.user_id = auth.uid() AND e.course_id = ex.course_id))
        OR ex.created_by = auth.uid()
      )
    )
  );
CREATE POLICY "Teachers manage questions" ON public.exam_questions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.exams ex WHERE ex.id = exam_questions.exam_id AND ex.created_by = auth.uid())
  );

-- Exam options: visible if question is visible
CREATE POLICY "View exam options" ON public.exam_options
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.exam_questions eq
      JOIN public.exams ex ON ex.id = eq.exam_id
      WHERE eq.id = exam_options.question_id
      AND (
        (ex.is_published = true AND EXISTS (SELECT 1 FROM public.enrollments e WHERE e.user_id = auth.uid() AND e.course_id = ex.course_id))
        OR ex.created_by = auth.uid()
      )
    )
  );
CREATE POLICY "Teachers manage options" ON public.exam_options
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.exam_questions eq
      JOIN public.exams ex ON ex.id = eq.exam_id
      WHERE eq.id = exam_options.question_id AND ex.created_by = auth.uid()
    )
  );

-- Exam attempts: students see own
CREATE POLICY "Students view own attempts" ON public.exam_attempts
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Students create attempts" ON public.exam_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Students update own attempts" ON public.exam_attempts
  FOR UPDATE USING (auth.uid() = user_id);
-- Teachers can view attempts for their exams
CREATE POLICY "Teachers view exam attempts" ON public.exam_attempts
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.exams ex WHERE ex.id = exam_attempts.exam_id AND ex.created_by = auth.uid())
  );

-- Exam answers: students see own
CREATE POLICY "Students view own answers" ON public.exam_answers
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.exam_attempts att WHERE att.id = exam_answers.attempt_id AND att.user_id = auth.uid())
  );
CREATE POLICY "Students create answers" ON public.exam_answers
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.exam_attempts att WHERE att.id = exam_answers.attempt_id AND att.user_id = auth.uid())
  );

-- Chats: members only
CREATE POLICY "View chats as member" ON public.chats
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = chats.id AND cm.user_id = auth.uid())
  );

-- Chat members: see own memberships
CREATE POLICY "View own memberships" ON public.chat_members
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "View co-members" ON public.chat_members
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = chat_members.chat_id AND cm.user_id = auth.uid())
  );

-- Messages: chat members can view and send
CREATE POLICY "Members view messages" ON public.messages
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = messages.chat_id AND cm.user_id = auth.uid())
  );
CREATE POLICY "Members send messages" ON public.messages
  FOR INSERT WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = messages.chat_id AND cm.user_id = auth.uid())
  );

-- ============================================================
-- PART 5: INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_users_university_id ON public.users(university_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_groups_level ON public.groups(level_id);
CREATE INDEX IF NOT EXISTS idx_sections_group ON public.sections(group_id);
CREATE INDEX IF NOT EXISTS idx_courses_level ON public.courses(level_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON public.enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course ON public.enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_assignments_user ON public.assignments(user_id);
CREATE INDEX IF NOT EXISTS idx_assignments_course ON public.assignments(course_id);
CREATE INDEX IF NOT EXISTS idx_lectures_course ON public.lectures(course_id);
CREATE INDEX IF NOT EXISTS idx_lectures_created_by ON public.lectures(created_by);
CREATE INDEX IF NOT EXISTS idx_requirements_course ON public.requirements(course_id);
CREATE INDEX IF NOT EXISTS idx_exams_course ON public.exams(course_id);
CREATE INDEX IF NOT EXISTS idx_exam_questions_exam ON public.exam_questions(exam_id);
CREATE INDEX IF NOT EXISTS idx_exam_options_question ON public.exam_options(question_id);
CREATE INDEX IF NOT EXISTS idx_exam_attempts_user ON public.exam_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_exam_attempts_exam ON public.exam_attempts(exam_id);
CREATE INDEX IF NOT EXISTS idx_exam_answers_attempt ON public.exam_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_chat_members_chat ON public.chat_members(chat_id);
CREATE INDEX IF NOT EXISTS idx_chat_members_user ON public.chat_members(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat ON public.messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON public.messages(created_at DESC);

-- ============================================================
-- PART 6: AUTO-CREATE USER PROFILE TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.users (id, university_id, full_name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'university_id', NEW.id::text),
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  );
  RETURN NEW;
END;
$$;

-- Drop existing trigger if any
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- PART 7: UPDATED_AT TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_lectures_updated_at
  BEFORE UPDATE ON public.lectures
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON public.messages
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================================
-- PART 8: ENABLE REALTIME FOR MESSAGES
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;

-- ============================================================
-- PART 9: DEMO SEED DATA
-- ============================================================

-- Levels
INSERT INTO public.levels (id, name, name_ar, "order") VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Level 1', 'المستوى الأول', 1),
  ('a1000000-0000-0000-0000-000000000002', 'Level 2', 'المستوى الثاني', 2),
  ('a1000000-0000-0000-0000-000000000003', 'Level 3', 'المستوى الثالث', 3),
  ('a1000000-0000-0000-0000-000000000004', 'Level 4', 'المستوى الرابع', 4)
ON CONFLICT DO NOTHING;

-- Groups
INSERT INTO public.groups (id, level_id, name, name_ar) VALUES
  ('b1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Group A', 'مجموعة أ'),
  ('b1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Group B', 'مجموعة ب'),
  ('b1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000002', 'Group A', 'مجموعة أ'),
  ('b1000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000002', 'Group B', 'مجموعة ب')
ON CONFLICT DO NOTHING;

-- Sections
INSERT INTO public.sections (id, group_id, name, name_ar) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Section 1', 'سكشن 1'),
  ('c1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Section 2', 'سكشن 2'),
  ('c1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Section 1', 'سكشن 1'),
  ('c1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000003', 'Section 1', 'سكشن 1')
ON CONFLICT DO NOTHING;

-- Courses
INSERT INTO public.courses (id, code, name, name_ar, description, credit_hours, level_id, semester) VALUES
  ('d1000000-0000-0000-0000-000000000001', 'CS101', 'Introduction to Computer Science', 'مقدمة في علوم الحاسب', 'Fundamental concepts of CS including algorithms and data structures', 3, 'a1000000-0000-0000-0000-000000000001', 'Fall 2024'),
  ('d1000000-0000-0000-0000-000000000002', 'MATH201', 'Calculus I', 'تفاضل وتكامل 1', 'Limits, derivatives, and integrals', 4, 'a1000000-0000-0000-0000-000000000001', 'Fall 2024'),
  ('d1000000-0000-0000-0000-000000000003', 'PHY101', 'Physics I', 'فيزياء 1', 'Classical mechanics and thermodynamics', 3, 'a1000000-0000-0000-0000-000000000001', 'Fall 2024'),
  ('d1000000-0000-0000-0000-000000000004', 'CS201', 'Data Structures', 'هياكل البيانات', 'Arrays, linked lists, trees, graphs', 3, 'a1000000-0000-0000-0000-000000000002', 'Spring 2025'),
  ('d1000000-0000-0000-0000-000000000005', 'CS301', 'Database Systems', 'نظم قواعد البيانات', 'Relational databases, SQL, normalization', 3, 'a1000000-0000-0000-0000-000000000002', 'Spring 2025'),
  ('d1000000-0000-0000-0000-000000000006', 'CS401', 'Artificial Intelligence', 'الذكاء الاصطناعي', 'Machine learning, neural networks, NLP', 3, 'a1000000-0000-0000-0000-000000000003', 'Fall 2025')
ON CONFLICT (code) DO NOTHING;

-- Course prerequisites
INSERT INTO public.course_prerequisites (course_id, prerequisite_id) VALUES
  ('d1000000-0000-0000-0000-000000000004', 'd1000000-0000-0000-0000-000000000001'),
  ('d1000000-0000-0000-0000-000000000005', 'd1000000-0000-0000-0000-000000000001'),
  ('d1000000-0000-0000-0000-000000000006', 'd1000000-0000-0000-0000-000000000004')
ON CONFLICT DO NOTHING;
