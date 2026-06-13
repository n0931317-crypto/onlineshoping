-- ============================================================
-- MESSAGES TABLE SETUP FOR CONTACT FORM
-- ============================================================

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_messages_email ON messages(email);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_is_read ON messages(is_read);

-- Enable Row Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "view_all_messages" ON messages;
DROP POLICY IF EXISTS "anyone_insert_messages" ON messages;
DROP POLICY IF EXISTS "anyone_update_messages" ON messages;
DROP POLICY IF EXISTS "anyone_delete_messages" ON messages;

-- RLS Policy: Everyone can view all messages
CREATE POLICY "view_all_messages"
ON messages
FOR SELECT
USING (true);

-- RLS Policy: Anyone can insert messages
CREATE POLICY "anyone_insert_messages"
ON messages
FOR INSERT
WITH CHECK (true);

-- RLS Policy: Anyone can update messages
CREATE POLICY "anyone_update_messages"
ON messages
FOR UPDATE
USING (true)
WITH CHECK (true);

-- RLS Policy: Anyone can delete messages
CREATE POLICY "anyone_delete_messages"
ON messages
FOR DELETE
USING (true);

-- Verify the table
SELECT * FROM messages LIMIT 5;
