const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function testJoin() {
  console.log("Checking Students Join...");
  const { data: s, error: se } = await supabase
    .from('users')
    .select('*, levels(name), sections(name), enrollments(courses(code))')
    .eq('role', 'student')
    .limit(1);
  if (se) console.error("Student Join Error:", se.message);
  else console.log("Student Join OK");

  console.log("Checking Doctors Join...");
  const { data: d, error: de } = await supabase
    .from('users')
    .select('*, assignments(courses(code, name_ar))')
    .eq('role', 'doctor')
    .limit(1);
  if (de) console.error("Doctors Join Error:", de.message);
  else console.log("Doctors Join OK");
}
testJoin();
