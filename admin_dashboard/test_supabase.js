const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error("Missing URL or Key in .env.local");
  process.exit(1);
}

const supabaseAdmin = createClient(supabaseUrl, supabaseKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function test() {
  console.log("Testing auth connection...");
  const { data, error } = await supabaseAdmin.from('levels').select('*').limit(1);
  if (error) {
    console.error("Query Error:", error);
  } else {
    console.log("Success! Data:", data);
  }
}

test();
