import { NextRequest, NextResponse } from 'next/server';
import * as XLSX from 'xlsx';
import { supabaseAdmin } from '@/lib/supabase';

// ============================================
// API Route: POST /api/upload
// Processes Excel files and inserts into Supabase
// ============================================

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData();
    const file = formData.get('file') as File;
    const fileType = formData.get('type') as string; // 'courses' | 'students' | 'doctors' | 'tas'

    if (!file || !fileType) {
      return NextResponse.json({ error: 'Missing file or type' }, { status: 400 });
    }

    // Parse Excel file
    const buffer = await file.arrayBuffer();
    const workbook = XLSX.read(buffer, { type: 'array' });
    const sheet = workbook.Sheets[workbook.SheetNames[0]];
    const rows = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet);

    if (rows.length === 0) {
      return NextResponse.json({ error: 'الملف فاضي — مفيش بيانات' }, { status: 400 });
    }

    let result;
    switch (fileType) {
      case 'courses':
        result = await processCourses(rows);
        break;
      case 'students':
        result = await processStudents(rows);
        break;
      case 'doctors':
        result = await processDoctors(rows);
        break;
      case 'tas':
        result = await processTAs(rows);
        break;
      default:
        return NextResponse.json({ error: 'Invalid file type' }, { status: 400 });
    }

    return NextResponse.json(result);

  } catch (error: unknown) {
    console.error('Upload error:', error);
    const message = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json({ error: message }, { status: 500 });
  }
}

// ============================================
// 1. Process Courses (courses.xlsx)
// ============================================
async function processCourses(rows: Record<string, unknown>[]) {
  const results = { total: rows.length, success: 0, errors: [] as string[] };

  // Collect unique levels
  const levelSet = new Set<string>();
  for (const row of rows) {
    const level = String(row['level'] || '').trim();
    if (level) levelSet.add(level);
  }

  // Create levels
  const levelMap: Record<string, string> = {};
  for (const levelName of levelSet) {
    const { data, error } = await supabaseAdmin
      .from('levels')
      .upsert({ name: `Level ${levelName}`, name_ar: `المستوى ${levelName}`, order: parseInt(levelName) }, { onConflict: 'name' })
      .select('id')
      .single();
    
    if (error) {
      // Try to get existing
      const { data: existing } = await supabaseAdmin
        .from('levels')
        .select('id')
        .eq('name', `Level ${levelName}`)
        .single();
      if (existing) levelMap[levelName] = existing.id;
      else results.errors.push(`Level ${levelName}: ${error.message}`);
    } else if (data) {
      levelMap[levelName] = data.id;
    }
  }

  // Create courses
  for (const row of rows) {
    const code = String(row['code'] || '').trim();
    const name = String(row['name'] || '').trim();
    const nameAr = String(row['name_ar'] || '').trim();
    const creditHours = parseInt(String(row['credit_hours'] || '3'));
    const level = String(row['level'] || '').trim();
    const semester = String(row['semester'] || '').trim();
    const hasSections = String(row['has_sections'] || 'yes').toLowerCase() === 'yes';

    if (!code || !name) {
      results.errors.push(`Row skipped: missing code or name`);
      continue;
    }

    const { error } = await supabaseAdmin
      .from('courses')
      .upsert({
        code,
        name,
        name_ar: nameAr || null,
        credit_hours: creditHours,
        level_id: levelMap[level] || null,
        semester: semester || null,
        has_sections: hasSections,
      }, { onConflict: 'code' });

    if (error) {
      results.errors.push(`${code}: ${error.message}`);
    } else {
      results.success++;
    }
  }

  return results;
}

// ============================================
// 2. Process Students (students.xlsx)
// ============================================
async function processStudents(rows: Record<string, unknown>[]) {
  const results = { total: rows.length, success: 0, errors: [] as string[] };

  // Get levels & sections maps
  const { data: levels } = await supabaseAdmin.from('levels').select('id, name');
  const levelMap: Record<string, string> = {};
  (levels || []).forEach(l => {
    const num = l.name.replace('Level ', '');
    levelMap[num] = l.id;
  });

  // Create sections if needed and build map
  const sectionMap: Record<string, string> = {}; // "level_section" -> id

  for (const row of rows) {
    const level = String(row['level'] || '').trim();
    const section = String(row['section'] || '').trim();
    const key = `${level}_${section}`;

    if (level && section && !sectionMap[key] && levelMap[level]) {
      const { data, error } = await supabaseAdmin
        .from('sections')
        .upsert({
          level_id: levelMap[level],
          name: `Section ${section}`,
          name_ar: `سكشن ${section}`,
        }, { onConflict: 'level_id,name' })
        .select('id')
        .single();

      if (data) {
        sectionMap[key] = data.id;
      } else if (error) {
        // Try to find existing
        const { data: existing } = await supabaseAdmin
          .from('sections')
          .select('id')
          .eq('level_id', levelMap[level])
          .eq('name', `Section ${section}`)
          .single();
        if (existing) sectionMap[key] = existing.id;
      }
    }
  }

  // Get courses map
  const { data: courses } = await supabaseAdmin.from('courses').select('id, code');
  const courseMap: Record<string, string> = {};
  (courses || []).forEach(c => { courseMap[c.code] = c.id; });

  // Process each student
  for (const row of rows) {
    const universityId = String(row['university_id'] || '').trim();
    const password = String(row['password'] || '').trim();
    const fullName = String(row['full_name'] || '').trim();
    const level = String(row['level'] || '').trim();
    const section = String(row['section'] || '').trim();
    const coursesStr = String(row['courses'] || '').trim();

    if (!universityId || !password || !fullName) {
      results.errors.push(`Row skipped: missing university_id, password, or full_name`);
      continue;
    }

    const email = `${universityId}@scholar.uni`;

    // 1. Create Supabase Auth user
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        university_id: universityId,
        full_name: fullName,
        role: 'student',
      }
    });

    let userId: string;

    if (authError) {
      if (authError.message.includes('already') || authError.message.includes('exists')) {
        // Try to find existing user ID by university_id
        const { data: existing } = await supabaseAdmin
          .from('users')
          .select('id')
          .eq('university_id', universityId)
          .maybeSingle();

        if (existing) {
          userId = existing.id;
        } else {
          // If not in public.users, try to get from auth.admin.listUsers
          const { data: authUsers } = await supabaseAdmin.auth.admin.listUsers();
          const authUser = authUsers.users.find(u => u.email === email);
          if (authUser) {
            userId = authUser.id;
          } else {
            results.errors.push(`${universityId}: ${authError.message}`);
            continue;
          }
        }
      } else {
        results.errors.push(`${universityId}: ${authError.message}`);
        continue;
      }
    } else {
      userId = authData.user.id;
    }

    // 2. Upsert user profile
    const sectionKey = `${level}_${section}`;
    await supabaseAdmin.from('users').upsert({
      id: userId,
      university_id: universityId,
      full_name: fullName,
      role: 'student',
      plain_password: password,
      level_id: levelMap[level] || null,
      section_id: sectionMap[sectionKey] || null,
    }, { onConflict: 'university_id' });

    // 3. Enroll in courses
    if (coursesStr) {
      const courseCodes = coursesStr.split(',').map(c => c.trim());
      for (const code of courseCodes) {
        if (courseMap[code]) {
          await supabaseAdmin.from('enrollments').upsert({
            user_id: userId,
            course_id: courseMap[code],
            section_id: sectionMap[sectionKey] || null,
          }, { onConflict: 'user_id,course_id' });
        } else {
          results.errors.push(`${universityId}: مادة ${code} مش موجودة`);
        }
      }
    }

    results.success++;
  }

  return results;
}

// ============================================
// 3. Process Doctors (doctors.xlsx)
// ============================================
async function processDoctors(rows: Record<string, unknown>[]) {
  const results = { total: rows.length, success: 0, errors: [] as string[] };

  // Get courses map
  const { data: courses } = await supabaseAdmin.from('courses').select('id, code');
  const courseMap: Record<string, string> = {};
  (courses || []).forEach(c => { courseMap[c.code] = c.id; });

  for (const row of rows) {
    const universityId = String(row['university_id'] || '').trim();
    const password = String(row['password'] || '').trim();
    const fullName = String(row['full_name'] || '').trim();
    const courseCodes = String(row['course_codes'] || '').trim();

    if (!universityId || !password || !fullName) {
      results.errors.push(`Row skipped: missing data`);
      continue;
    }

    const email = `${universityId}@scholar.uni`;

    // 1. Create Auth user
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        university_id: universityId,
        full_name: fullName,
        role: 'doctor',
      }
    });

    let userId: string;

    if (authError) {
      if (authError.message.includes('already') || authError.message.includes('exists')) {
          const { data: existing } = await supabaseAdmin.from('users').select('id').eq('university_id', universityId).maybeSingle();
          if (existing) {
            userId = existing.id;
          } else {
            const { data: authUsers } = await supabaseAdmin.auth.admin.listUsers();
            const authUser = authUsers.users.find(u => u.email === email);
            if (authUser) userId = authUser.id;
            else { results.errors.push(`${universityId}: ${authError.message}`); continue; }
          }
      } else {
        results.errors.push(`${universityId}: ${authError.message}`);
        continue;
      }
    } else {
      userId = authData.user.id;
    }

    // 2. Upsert profile
    await supabaseAdmin.from('users').upsert({
      id: userId,
      university_id: universityId,
      full_name: fullName,
      plain_password: password,
      role: 'doctor'
    }, { onConflict: 'university_id' });

    // 3. Assign to courses
    if (courseCodes) {
      const codes = courseCodes.split(',').map(c => c.trim());
      for (const code of codes) {
        if (courseMap[code]) {
          // Check if already assigned
          const { data: existing } = await supabaseAdmin
            .from('assignments')
            .select('id')
            .eq('user_id', userId)
            .eq('course_id', courseMap[code])
            .eq('scope', 'course')
            .maybeSingle();
          if (!existing) {
            await supabaseAdmin.from('assignments').insert({
              user_id: userId,
              course_id: courseMap[code],
              scope: 'course',
              scope_id: null,
              role: 'doctor',
            });
          }
        } else {
          results.errors.push(`${universityId}: مادة ${code} مش موجودة`);
        }
      }
    }

    results.success++;
  }

  return results;
}

// ============================================
// 4. Process TAs (tas.xlsx)
// ============================================
async function processTAs(rows: Record<string, unknown>[]) {
  const results = { total: rows.length, success: 0, errors: [] as string[] };

  // Get courses map
  const { data: courses } = await supabaseAdmin.from('courses').select('id, code, level_id');
  const courseMap: Record<string, { id: string; level_id: string }> = {};
  (courses || []).forEach(c => { courseMap[c.code] = { id: c.id, level_id: c.level_id }; });

  // Get sections
  const { data: sections } = await supabaseAdmin.from('sections').select('id, level_id, name');
  const sectionLookup: Record<string, string> = {}; // "levelId_Section X" -> id
  (sections || []).forEach(s => { sectionLookup[`${s.level_id}_${s.name}`] = s.id; });

  // Track created TAs to avoid duplicates
  const createdTAs: Record<string, string> = {}; // university_id -> userId

  for (const row of rows) {
    const universityId = String(row['university_id'] || '').trim();
    const password = String(row['password'] || '').trim();
    const fullName = String(row['full_name'] || '').trim();
    const courseCode = String(row['course_code'] || '').trim();
    const sectionsStr = String(row['sections'] || '').trim();

    if (!universityId || !password || !fullName) {
      results.errors.push(`Row skipped: missing data`);
      continue;
    }

    let userId = createdTAs[universityId];

    if (!userId) {
      const email = `${universityId}@scholar.uni`;

      // Create Auth user
      const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          university_id: universityId,
          full_name: fullName,
          role: 'ta',
        }
      });

      if (authError) {
        if (authError.message.includes('already') || authError.message.includes('exists')) {
          // Try to find existing user in public.users
          const { data: existing } = await supabaseAdmin.from('users').select('id').eq('university_id', universityId).maybeSingle();
          if (existing) {
            userId = existing.id;
          } else {
            // Fallback to auth.listUsers
            const { data: authUsers } = await supabaseAdmin.auth.admin.listUsers();
            const authUser = authUsers.users.find(u => u.email === email);
            if (authUser) userId = authUser.id;
            else { results.errors.push(`${universityId}: ${authError.message}`); continue; }
          }
        } else {
          results.errors.push(`${universityId}: ${authError.message}`);
          continue;
        }
      } else {
        userId = authData.user.id;
      }
      createdTAs[universityId] = userId;

      // 1.5. Upsert public profile for TA
      await supabaseAdmin.from('users').upsert({
        id: userId,
        university_id: universityId,
        full_name: fullName,
        plain_password: password,
        role: 'ta'
      }, { onConflict: 'university_id' });
    }

    // Assign to course sections
    if (courseCode && courseMap[courseCode]) {
      const course = courseMap[courseCode];
      const sectionNums = sectionsStr.split(',').map(s => s.trim());

      for (const secNum of sectionNums) {
        const sectionKey = `${course.level_id}_Section ${secNum}`;
        const sectionId = sectionLookup[sectionKey];

        if (sectionId) {
          // Check if already assigned
          const { data: existingAssign } = await supabaseAdmin
            .from('assignments')
            .select('id')
            .eq('user_id', userId)
            .eq('course_id', course.id)
            .eq('scope', 'section')
            .eq('scope_id', sectionId)
            .maybeSingle();
          if (!existingAssign) {
            await supabaseAdmin.from('assignments').insert({
              user_id: userId,
              course_id: course.id,
              scope: 'section',
              scope_id: sectionId,
              role: 'ta',
            });
          }
        } else {
          results.errors.push(`${universityId}: سكشن ${secNum} مش موجود للمادة ${courseCode}`);
        }
      }
    } else if (courseCode) {
      results.errors.push(`${universityId}: مادة ${courseCode} مش موجودة`);
    }

    results.success++;
  }

  return results;
}
