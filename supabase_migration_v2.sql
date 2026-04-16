-- ============================================
-- AI Study App — Database Schema v2
-- Updated: Removed groups, added grades, 
-- added has_sections, lecture type, attendance
-- ============================================

-- =====================
-- 0. CLEANUP OLD SCHEMA
-- =====================
DROP TABLE IF EXISTS exam_answers CASCADE;
DROP TABLE IF EXISTS exam_attempts CASCADE;
DROP TABLE IF EXISTS exam_options CASCADE;
DROP TABLE IF EXISTS exam_questions CASCADE;
DROP TABLE IF EXISTS exams CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS chat_members CASCADE;
DROP TABLE IF EXISTS chats CASCADE;
DROP TABLE IF EXISTS grades CASCADE;
DROP TABLE IF EXISTS requirements CASCADE;
DROP TABLE IF EXISTS lectures CASCADE;
DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS course_prerequisites CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS sections CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS levels CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Drop old trigger/function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();
DROP TRIGGER IF EXISTS set_updated_at ON public.users;
DROP FUNCTION IF EXISTS update_updated_at();

-- =====================
-- 1. CORE TABLES
-- =====================

-- Levels (السنوات الدراسية)
CREATE TABLE public.levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_ar TEXT,
  "order" INT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Sections (السكاشن — تابعة للمستوى مباشرة، مفيش groups)
CREATE TABLE public.sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level_id UUID NOT NULL REFERENCES public.levels(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_ar TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Users (كل المستخدمين: طالب، دكتور، معيد، أدمن)
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  university_id TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  email TEXT,
  role TEXT NOT NULL CHECK (role IN ('student', 'doctor', 'ta', 'admin')),
  level_id UUID REFERENCES public.levels(id),
  section_id UUID REFERENCES public.sections(id),
  avatar_url TEXT,
  phone TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================
-- 2. COURSES
-- =====================

-- Courses (المواد)
CREATE TABLE public.courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  name_ar TEXT,
  description TEXT,
  credit_hours INT DEFAULT 3,
  level_id UUID REFERENCES public.levels(id),
  semester TEXT,
  has_sections BOOLEAN NOT NULL DEFAULT true,
  thumbnail_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Course Prerequisites
CREATE TABLE public.course_prerequisites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  prerequisite_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  UNIQUE(course_id, prerequisite_id)
);

-- =====================
-- 3. ENROLLMENT & ASSIGNMENTS
-- =====================

-- Enrollments (تسجيل الطلاب في المواد)
CREATE TABLE public.enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  section_id UUID REFERENCES public.sections(id),
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'dropped', 'completed')),
  enrolled_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, course_id)
);

-- Assignments (تعيين دكاترة ومعيدين)
CREATE TABLE public.assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  scope TEXT NOT NULL CHECK (scope IN ('course', 'section')),
  scope_id UUID, -- section_id if scope='section'
  role TEXT NOT NULL CHECK (role IN ('doctor', 'ta')),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, course_id, scope, scope_id)
);

-- =====================
-- 4. CONTENT
-- =====================

-- Lectures (محاضرات نظري + عملي)
CREATE TABLE public.lectures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  title_ar TEXT,
  description TEXT,
  video_url TEXT,
  pdf_url TEXT,
  "order" INT DEFAULT 0,
  duration_minutes INT,
  type TEXT NOT NULL DEFAULT 'lecture' CHECK (type IN ('lecture', 'practical')),
  section_id UUID REFERENCES public.sections(id), -- NULL for lectures, set for practical
  is_published BOOLEAN DEFAULT false,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Requirements (واجبات ومتطلبات)
CREATE TABLE public.requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT DEFAULT 'assignment' CHECK (type IN ('assignment', 'project', 'quiz', 'other')),
  file_url TEXT,
  link_url TEXT,
  due_date TIMESTAMPTZ,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =====================
-- 5. GRADES (نظام الدرجات)
-- =====================

CREATE TABLE public.grades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_id UUID NOT NULL REFERENCES public.enrollments(id) ON DELETE CASCADE UNIQUE,
  midterm NUMERIC(4,1) DEFAULT 0,      -- /15
  oral NUMERIC(4,1) DEFAULT 0,         -- /10
  practical NUMERIC(4,1) DEFAULT 0,    -- /10
  attendance NUMERIC(3,1) DEFAULT 0,   -- /5
  final NUMERIC(4,1) DEFAULT 0,        -- /60
  total NUMERIC(5,1) GENERATED ALWAYS AS (midterm + oral + practical + attendance + final) STORED,  -- /100
  grade_letter TEXT,
  updated_by UUID REFERENCES public.users(id),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================
-- 6. CHAT SYSTEM
-- =====================

CREATE TABLE public.chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('course', 'section', 'direct')),
  name TEXT,
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  section_id UUID REFERENCES public.sections(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.chat_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(chat_id, user_id)
);

CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  type TEXT DEFAULT 'text' CHECK (type IN ('text', 'image', 'file', 'system')),
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =====================
-- 7. INDEXES
-- =====================

CREATE INDEX idx_users_university_id ON public.users(university_id);
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_users_level ON public.users(level_id);
CREATE INDEX idx_users_section ON public.users(section_id);
CREATE INDEX idx_sections_level ON public.sections(level_id);
CREATE INDEX idx_courses_code ON public.courses(code);
CREATE INDEX idx_courses_level ON public.courses(level_id);
CREATE INDEX idx_enrollments_user ON public.enrollments(user_id);
CREATE INDEX idx_enrollments_course ON public.enrollments(course_id);
CREATE INDEX idx_enrollments_section ON public.enrollments(section_id);
CREATE INDEX idx_assignments_user ON public.assignments(user_id);
CREATE INDEX idx_assignments_course ON public.assignments(course_id);
CREATE INDEX idx_grades_enrollment ON public.grades(enrollment_id);
CREATE INDEX idx_lectures_course ON public.lectures(course_id);
CREATE INDEX idx_lectures_type ON public.lectures(type);
CREATE INDEX idx_lectures_section ON public.lectures(section_id);
CREATE INDEX idx_messages_chat ON public.messages(chat_id);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_chat_members_user ON public.chat_members(user_id);
CREATE INDEX idx_chat_members_chat ON public.chat_members(chat_id);

-- =====================
-- 8. TRIGGERS
-- =====================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_grades_updated_at
  BEFORE UPDATE ON public.grades
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create user profile when auth user registers
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, university_id, full_name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'university_id', NEW.id::text),
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'student')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Auto-calculate grade letter
CREATE OR REPLACE FUNCTION calculate_grade_letter()
RETURNS TRIGGER AS $$
BEGIN
  NEW.grade_letter := CASE
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 90 THEN 'A+'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 85 THEN 'A'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 80 THEN 'A-'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 75 THEN 'B+'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 70 THEN 'B'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 65 THEN 'B-'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 60 THEN 'C+'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 55 THEN 'C'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 50 THEN 'C-'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 45 THEN 'D+'
    WHEN (NEW.midterm + NEW.oral + NEW.practical + NEW.attendance + NEW.final) >= 40 THEN 'D'
    ELSE 'F'
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_grade_letter
  BEFORE INSERT OR UPDATE ON public.grades
  FOR EACH ROW EXECUTE FUNCTION calculate_grade_letter();

-- =====================
-- 9. RLS POLICIES
-- =====================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lectures ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Users: everyone can read, update own
CREATE POLICY "Users: read all" ON public.users FOR SELECT USING (true);
CREATE POLICY "Users: update own" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users: service insert" ON public.users FOR INSERT WITH CHECK (true);

-- Levels & Sections: read all
CREATE POLICY "Levels: read all" ON public.levels FOR SELECT USING (true);
CREATE POLICY "Levels: service insert" ON public.levels FOR INSERT WITH CHECK (true);
CREATE POLICY "Sections: read all" ON public.sections FOR SELECT USING (true);
CREATE POLICY "Sections: service insert" ON public.sections FOR INSERT WITH CHECK (true);

-- Courses: read all
CREATE POLICY "Courses: read all" ON public.courses FOR SELECT USING (true);
CREATE POLICY "Courses: service insert" ON public.courses FOR INSERT WITH CHECK (true);

-- Enrollments: students see own, doctors see their course students
CREATE POLICY "Enrollments: read own" ON public.enrollments FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (SELECT 1 FROM public.assignments a WHERE a.course_id = enrollments.course_id AND a.user_id = auth.uid())
  );
CREATE POLICY "Enrollments: service insert" ON public.enrollments FOR INSERT WITH CHECK (true);

-- Assignments: read all
CREATE POLICY "Assignments: read all" ON public.assignments FOR SELECT USING (true);
CREATE POLICY "Assignments: service insert" ON public.assignments FOR INSERT WITH CHECK (true);

-- Lectures: students see published for their courses, doctors/TAs manage own
CREATE POLICY "Lectures: read enrolled" ON public.lectures FOR SELECT
  USING (
    (is_published = true AND EXISTS (SELECT 1 FROM public.enrollments e WHERE e.course_id = lectures.course_id AND e.user_id = auth.uid())) OR
    created_by = auth.uid() OR
    EXISTS (SELECT 1 FROM public.assignments a WHERE a.course_id = lectures.course_id AND a.user_id = auth.uid())
  );
CREATE POLICY "Lectures: doctor/ta insert" ON public.lectures FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.assignments a WHERE a.course_id = lectures.course_id AND a.user_id = auth.uid())
  );
CREATE POLICY "Lectures: creator update" ON public.lectures FOR UPDATE USING (created_by = auth.uid());
CREATE POLICY "Lectures: creator delete" ON public.lectures FOR DELETE USING (created_by = auth.uid());

-- Grades: students see own, doctors see their course
CREATE POLICY "Grades: read own" ON public.grades FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM public.enrollments e WHERE e.id = grades.enrollment_id AND e.user_id = auth.uid()) OR
    EXISTS (
      SELECT 1 FROM public.enrollments e
      JOIN public.assignments a ON a.course_id = e.course_id
      WHERE e.id = grades.enrollment_id AND a.user_id = auth.uid() AND a.role = 'doctor'
    )
  );
CREATE POLICY "Grades: doctor insert" ON public.grades FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.enrollments e
      JOIN public.assignments a ON a.course_id = e.course_id
      WHERE e.id = grades.enrollment_id AND a.user_id = auth.uid() AND a.role = 'doctor'
    )
  );
CREATE POLICY "Grades: doctor update" ON public.grades FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.enrollments e
      JOIN public.assignments a ON a.course_id = e.course_id
      WHERE e.id = grades.enrollment_id AND a.user_id = auth.uid() AND a.role = 'doctor'
    )
  );

-- Chat: members only
CREATE POLICY "Chats: member read" ON public.chats FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = chats.id AND cm.user_id = auth.uid()));
CREATE POLICY "Chat members: read own" ON public.chat_members FOR SELECT
  USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = chat_members.chat_id AND cm.user_id = auth.uid()));
CREATE POLICY "Chat members: service insert" ON public.chat_members FOR INSERT WITH CHECK (true);

-- Messages: chat members only
CREATE POLICY "Messages: member read" ON public.messages FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = messages.chat_id AND cm.user_id = auth.uid()));
CREATE POLICY "Messages: member insert" ON public.messages FOR INSERT
  WITH CHECK (sender_id = auth.uid() AND EXISTS (SELECT 1 FROM public.chat_members cm WHERE cm.chat_id = messages.chat_id AND cm.user_id = auth.uid()));

-- Requirements
CREATE POLICY "Requirements: read enrolled" ON public.requirements FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.enrollments e WHERE e.course_id = requirements.course_id AND e.user_id = auth.uid()) OR
         EXISTS (SELECT 1 FROM public.assignments a WHERE a.course_id = requirements.course_id AND a.user_id = auth.uid()));
CREATE POLICY "Requirements: service insert" ON public.requirements FOR INSERT WITH CHECK (true);

-- =====================
-- 10. ENABLE REALTIME
-- =====================
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
