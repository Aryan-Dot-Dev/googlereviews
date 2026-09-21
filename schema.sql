-- ============================================================
-- Neon setup for the pitch/lead page (pitch.html)
--
-- 1. Create a project at https://console.neon.tech
-- 2. Open the SQL Editor, paste this whole file, run it.
-- 3. Create the connection string for the *restricted* role:
--      postgresql://leads_writer:YOUR_PASSWORD@<host>/<dbname>?sslmode=require
--    (Neon console → Connect → pick the leads_writer role / or hand-edit
--     the main connection string, replacing user and password.)
-- 4. Paste that connection string into pitch.html → CONFIG.neonConnectionString
--
-- NOTE: pitch.html is a public page, so the connection string ships to
-- every visitor's browser. That is why this script creates a role that
-- can ONLY insert rows into `leads` — it cannot read, update or delete
-- anything. Never paste a privileged (owner/admin) connection string
-- into a public page.
-- ============================================================

CREATE TABLE IF NOT EXISTS leads (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  name         TEXT NOT NULL,
  phone        TEXT NOT NULL,
  business     TEXT NOT NULL,
  city         TEXT,
  meeting      BOOLEAN NOT NULL DEFAULT FALSE,
  meeting_slot TEXT,
  message      TEXT,
  source       TEXT NOT NULL DEFAULT 'pitch-page',
  user_agent   TEXT
);

-- Insert-only role used by pitch.html ------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'leads_writer') THEN
    CREATE ROLE leads_writer LOGIN PASSWORD 'CHANGE-ME-strong-password';
  END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO leads_writer;
GRANT INSERT ON leads TO leads_writer;
GRANT USAGE ON SEQUENCE leads_id_seq TO leads_writer;

-- (Optional) prevent the writer role from setting its own connection
-- properties persistently — keeps things tidy if the string leaks.
ALTER ROLE leads_writer SET statement_timeout = '10s';
