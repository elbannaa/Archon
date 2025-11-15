-- =====================================================
-- Archon Complete Database Setup (SAFE VERSION)
-- =====================================================
-- This version uses DROP IF EXISTS to safely re-run
-- =====================================================

-- =====================================================
-- SECTION 1: EXTENSIONS
-- =====================================================

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- =====================================================
-- SECTION 2: CREDENTIALS AND SETTINGS
-- =====================================================

CREATE TABLE IF NOT EXISTS archon_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key VARCHAR(255) UNIQUE NOT NULL,
    value TEXT,
    encrypted_value TEXT,
    is_encrypted BOOLEAN DEFAULT FALSE,
    category VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_archon_settings_key ON archon_settings(key);
CREATE INDEX IF NOT EXISTS idx_archon_settings_category ON archon_settings(category);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_archon_settings_updated_at ON archon_settings;
CREATE TRIGGER update_archon_settings_updated_at
    BEFORE UPDATE ON archon_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE archon_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow service role full access" ON archon_settings;
CREATE POLICY "Allow service role full access" ON archon_settings
    FOR ALL USING (auth.role() = 'service_role');

DROP POLICY IF EXISTS "Allow authenticated users to read and update" ON archon_settings;
CREATE POLICY "Allow authenticated users to read and update" ON archon_settings
    FOR ALL TO authenticated
    USING (true);

-- Continue with rest of setup but skip if already exists...
-- Just insert the settings data (ON CONFLICT DO NOTHING handles duplicates)
