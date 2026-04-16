const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
  console.log("--- Checking Users ---");
  const { data: users, error } = await supabase.from('users').select('university_id, role, full_name');
  if (error) console.error(error);
  else {
    console.log(`Found ${users.length} users in public.users table.`);
    users.forEach(u => console.log(`- [${u.role}] ${u.university_id}: ${u.full_name}`));
  }

  console.log("\n--- Checking Auth Users ---");
  const { data: authUsers, error: authError } = await supabase.auth.admin.listUsers();
  if (authError) console.error(authError);
  else {
    console.log(`Found ${authUsers.users.length} users in auth.users.`);
    authUsers.users.forEach(u => console.log(`- ${u.email} (ID: ${u.id})`));
  }
}

check();
