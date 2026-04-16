import React from 'react';
import { supabaseAdmin } from '@/lib/supabase';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import StudentsTableClient from './StudentsTableClient';

export default async function StudentsPage() {
  const { data: students, error } = await supabaseAdmin
    .from('users')
    .select('*, levels(name), sections(name), enrollments(courses(id, code, name_ar, name))')
    .eq('role', 'student')
    .order('university_id');

  // Fetch dropdown data for the modal
  const { data: levels } = await supabaseAdmin.from('levels').select('id, name');
  const { data: sections } = await supabaseAdmin.from('sections').select('id, name, level_id');
  const { data: courses } = await supabaseAdmin.from('courses').select('id, code, name, name_ar');

  if (error) {
    return <div className="p-8 text-center text-error">حدث خطأ أثناء تحميل البيانات</div>;
  }

  return (
    <div className="flex min-h-screen bg-background text-on-surface hover:bg-background">
      <Sidebar />
      <main className="lg:ml-72 flex-1 pb-24 lg:pb-12">
        <Header />
        <section className="px-6 md:px-8 mt-4">
          <div className="mb-8 flex justify-between items-end">
            <div>
              <p className="text-on-surface-variant font-medium mb-1 text-sm">إدارة البيانات</p>
              <h3 className="font-headline text-3xl font-bold text-primary mb-1 tracking-tight">الطلاب (Students)</h3>
            </div>
            <div className="bg-primary/10 text-primary px-4 py-2 rounded-xl font-bold text-sm">
              إجمالي الطلاب: {students?.length || 0}
            </div>
          </div>

          <StudentsTableClient 
            students={students} 
            levels={levels} 
            sections={sections} 
            courses={courses} 
          />
        </section>
      </main>
    </div>
  );
}
