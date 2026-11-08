-- 002_content_and_sessions.down.sql: Revert unique index and sessions table

DROP INDEX IF EXISTS idx_lessons_level_order_unique;
DROP TABLE IF EXISTS sessions;
ALTER TABLE lessons DROP COLUMN IF EXISTS display_no;
