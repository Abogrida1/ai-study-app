import React from 'react';
import { supabaseAdmin } from '@/lib/supabase-admin';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import TAsTableClient from './TAsTableClient';

export default async function TAsPage() {
  const { data: tas, error } = await supabaseAdmin
    .from('users')
    .select(`*, assignments(course_id, scope_id, courses(code, name, name_ar))`)
    .eq('role', 'ta')
    .order('university_id');

  // Fetch sections with their level info
  const { data: sections } = await supabaseAdmin
    .from('sections')
    .select('id, name, level_id');

  const { data: courses } = await supabaseAdmin
    .from('courses')
    .select('id, code, name, name_ar, level_id');

  if (error) {
    return <div className="p-8 text-center text-error">حدث خطأ أثناء تحميل البيانات</div>;
  }

  // Build sections lookup: sectionId -> section
  const sectionsMap: Record<string, any> = {};
  (sections || []).forEach(s => { sectionsMap[s.id] = s; });

  // Pre-compute: for each course, embed its matching sections
  // This way client receives fully ready data with no filtering needed
  const coursesWithSections = (courses || []).map(c => ({
    ...c,
    sections: (sections || []).filter(s => s.level_id === c.level_id)
  })).filter(c => c.sections.length > 0);

  return (
    <div className="flex min-h-screen bg-background text-on-surface hover:bg-background">
      <Sidebar />
      <main className="lg:ml-72 flex-1 pb-24 lg:pb-12">
        <Header />
        <section className="px-6 md:px-8 mt-4">
          <div className="mb-8 flex justify-between items-end">
            <div>
              <p className="text-on-surface-variant font-medium mb-1 text-sm">إدارة البيانات</p>
              <h3 className="font-headline text-3xl font-bold text-primary mb-1 tracking-tight">الهيئة المعاونة (Teaching Assistants)</h3>
            </div>
            <div className="bg-primary/10 text-primary px-4 py-2 rounded-xl font-bold text-sm">
              إجمالي المعيدين: {tas?.length || 0}
            </div>
          </div>

          <TAsTableClient 
            tas={tas} 
            sectionsMap={sectionsMap} 
            coursesWithSections={coursesWithSections}
          />
        </section>
      </main>
    </div>
  );
}
