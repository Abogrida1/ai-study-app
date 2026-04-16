'use server';

import { supabaseAdmin } from '@/lib/supabase-admin';
import { revalidatePath } from 'next/cache';

export async function deleteUser(userId: string) {
  try {
    // 1. Delete from Supabase Auth (this should cascade to public.users if setup correctly, but just in case we delete from auth)
    const { error: authError } = await supabaseAdmin.auth.admin.deleteUser(userId);
    if (authError) {
      // If user doesn't exist in auth, maybe just in public
      await supabaseAdmin.from('users').delete().eq('id', userId);
    }
    
    revalidatePath('/data/students');
    revalidatePath('/data/doctors');
    revalidatePath('/data/tas');
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

export async function updateStudent(userId: string, data: any, selectedCourses: string[]) {
  try {
    // 1. Update public.users
    const { error: userError } = await supabaseAdmin.from('users').update({
      full_name: data.full_name,
      university_id: data.university_id,
      plain_password: data.plain_password,
      level_id: data.level_id || null,
      section_id: data.section_id || null,
    }).eq('id', userId);

    if (userError) throw new Error(userError.message);

    // 2. Update Auth password if changed manually
    if (data.plain_password) {
      await supabaseAdmin.auth.admin.updateUserById(userId, { password: data.plain_password });
    }

    // 3. Update Enrollments
    // First remove all existing
    await supabaseAdmin.from('enrollments').delete().eq('user_id', userId);
    
    // Then re-insert
    if (selectedCourses && selectedCourses.length > 0) {
      const enrollments = selectedCourses.map(courseId => ({
        user_id: userId,
        course_id: courseId,
        section_id: data.section_id || null
      }));
      await supabaseAdmin.from('enrollments').insert(enrollments);
    }

    revalidatePath('/data/students');
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

export async function updateDoctor(userId: string, data: any, selectedCourses: string[]) {
  try {
    const { error: userError } = await supabaseAdmin.from('users').update({
      full_name: data.full_name,
      university_id: data.university_id,
      plain_password: data.plain_password,
    }).eq('id', userId);

    if (userError) throw new Error(userError.message);

    if (data.plain_password) {
      await supabaseAdmin.auth.admin.updateUserById(userId, { password: data.plain_password });
    }

    await supabaseAdmin.from('assignments').delete().eq('user_id', userId);
    
    if (selectedCourses && selectedCourses.length > 0) {
      const assigns = selectedCourses.map(courseId => ({
        user_id: userId,
        course_id: courseId,
        scope: 'course',
        role: 'doctor'
      }));
      await supabaseAdmin.from('assignments').insert(assigns);
    }

    revalidatePath('/data/doctors');
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

export async function updateTA(userId: string, data: any, selectedAssignments: {course_id: string, section_id: string}[]) {
  try {
    const { error: userError } = await supabaseAdmin.from('users').update({
      full_name: data.full_name,
      university_id: data.university_id,
      plain_password: data.plain_password,
    }).eq('id', userId);

    if (userError) throw new Error(userError.message);

    if (data.plain_password) {
      await supabaseAdmin.auth.admin.updateUserById(userId, { password: data.plain_password });
    }

    await supabaseAdmin.from('assignments').delete().eq('user_id', userId);
    
    if (selectedAssignments && selectedAssignments.length > 0) {
      const assigns = selectedAssignments.map(a => ({
        user_id: userId,
        course_id: a.course_id,
        scope: 'section',
        scope_id: a.section_id,
        role: 'ta'
      }));
      await supabaseAdmin.from('assignments').insert(assigns);
    }

    revalidatePath('/data/tas');
    return { success: true };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}
