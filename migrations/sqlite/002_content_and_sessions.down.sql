-- 002_content_and_sessions.down.sql: Revert unique index, sessions table, and display_no column

DROP INDEX IF EXISTS idx_lessons_level_order_unique;
DROP TABLE IF EXISTS sessions;
ALTER TABLE lessons DROP COLUMN display_no;
