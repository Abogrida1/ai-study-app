'use server';

import { supabaseAdmin } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

export async function deleteCourse(courseId: string) {
  try {
    const { error } = await supabaseAdmin.from('courses').delete().eq('id', courseId);
    if (error) throw new Error(error.message);
    
    revalidatePath('/data/courses');
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

export async function updateCourse(courseId: string, data: any) {
  try {
    const { error } = await supabaseAdmin.from('courses').update({
      code: data.code,
      name: data.name,
      name_ar: data.name_ar,
      credit_hours: data.credit_hours,
      has_sections: data.has_sections,
      semester: parseInt(data.semester),
      level_id: data.level_id || null,
    }).eq('id', courseId);

    if (error) throw new Error(error.message);

    revalidatePath('/data/courses');
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}
