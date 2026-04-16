import React from 'react';
import { supabaseAdmin } from '@/lib/supabase-admin';
import Sidebar from '@/components/Sidebar';
import Header from '@/components/Header';
import CoursesTableClient from './CoursesTableClient';

export default async function CoursesPage() {
  const { data: courses, error } = await supabaseAdmin
    .from('courses')
    .select('*, levels(name)')
    .order('code');

  const { data: levels } = await supabaseAdmin.from('levels').select('id, name');

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
              <h3 className="font-headline text-3xl font-bold text-primary mb-1 tracking-tight">المواد الدراسية (Courses)</h3>
            </div>
            <div className="bg-primary/10 text-primary px-4 py-2 rounded-xl font-bold text-sm">
              إجمالي المواد: {courses?.length || 0}
            </div>
          </div>

          <CoursesTableClient courses={courses} levels={levels} />
        </section>
      </main>
    </div>
  );
}
