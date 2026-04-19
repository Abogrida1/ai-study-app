-- ============================================
-- Add Foreign Key constraint for assignments.scope_id -> sections.id
-- This allows Supabase to properly join assignments with sections
-- ============================================

-- Add the foreign key constraint
ALTER TABLE public.assignments
ADD CONSTRAINT fk_assignments_scope_id_sections
FOREIGN KEY (scope_id) REFERENCES public.sections(id) ON DELETE CASCADE;

-- Verify the constraint was added
-- SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = 'assignments';
