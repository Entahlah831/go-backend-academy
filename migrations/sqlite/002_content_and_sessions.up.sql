-- 002_content_and_sessions.up.sql: Add display_no, unique index on (level_id, order_index), and sessions table

ALTER TABLE lessons ADD COLUMN display_no VARCHAR(16) NOT NULL DEFAULT '';

-- Align lesson ordering and display numbers across all levels
UPDATE lessons SET order_index = 1, display_no = '0.0A' WHERE id = 'l0-stage-a-what-is-backend';
UPDATE lessons SET order_index = 2, display_no = '0.0B' WHERE id = 'l0-stage-a-git-go-workspace';
UPDATE lessons SET order_index = 3, display_no = '0.1'  WHERE id = 'l0-backend-http-lifecycle';
UPDATE lessons SET order_index = 4, display_no = '0.2'  WHERE id = 'l0-stateless-vs-stateful-arch';
UPDATE lessons SET order_index = 5, display_no = '0.3'  WHERE id = 'l0-rest-json-api-contracts';

UPDATE lessons SET order_index = 1, display_no = '1.0A' WHERE id = 'l1-stage-b-variables-types-zerovalues';
UPDATE lessons SET order_index = 2, display_no = '1.0B' WHERE id = 'l1-stage-b-control-flow-loops-functions';
UPDATE lessons SET order_index = 3, display_no = '1.0C' WHERE id = 'l1-stage-b-slices-maps-iteration';
UPDATE lessons SET order_index = 4, display_no = '1.0D' WHERE id = 'l1-stage-b-structs-methods-pointers';
UPDATE lessons SET order_index = 5, display_no = '1.0E' WHERE id = 'l1-stage-b-interfaces-errors-fundamentals';
UPDATE lessons SET order_index = 6, display_no = '1.0F' WHERE id = 'l1-stage-b-json-files-unit-testing';
UPDATE lessons SET order_index = 7, display_no = '1.1'  WHERE id = 'l1-toolchain-modules-packages';
UPDATE lessons SET order_index = 8, display_no = '1.2'  WHERE id = 'l1-memory-slices-maps-escape';
UPDATE lessons SET order_index = 9, display_no = '1.3'  WHERE id = 'l1-interfaces-errors-generics';

UPDATE lessons SET order_index = 1, display_no = '2.0' WHERE id = 'l2-stage-c-goroutines-channels-waitgroup';
UPDATE lessons SET order_index = 2, display_no = '2.1' WHERE id = 'l2-gmp-channels-context-workers';
UPDATE lessons SET order_index = 3, display_no = '2.2' WHERE id = 'l2-profiling-pprof-benchmarks';

UPDATE lessons SET order_index = 1, display_no = '3.0' WHERE id = 'l3-stage-d-first-http-server-crud';
UPDATE lessons SET order_index = 2, display_no = '3.1' WHERE id = 'l3-net-http-routers';
UPDATE lessons SET order_index = 3, display_no = '3.2' WHERE id = 'l3-validation-openapi-ratelimit';

UPDATE lessons SET order_index = 1, display_no = '4.0' WHERE id = 'l4-stage-e-sql-relational-fundamentals';
UPDATE lessons SET order_index = 2, display_no = '4.1' WHERE id = 'l4-acid-isolation-mvcc';
UPDATE lessons SET order_index = 3, display_no = '4.2' WHERE id = 'l4-partitioning-replication-sharding';

UPDATE lessons SET order_index = 1, display_no = '5.0' WHERE id = 'l5-stage-e-database-sql-crud-basics';
UPDATE lessons SET order_index = 2, display_no = '5.1' WHERE id = 'l5-db-ecosystem-comparison';
UPDATE lessons SET order_index = 3, display_no = '5.2' WHERE id = 'l5-migrations-transactions-prepared';

UPDATE lessons SET order_index = 1, display_no = '6.0' WHERE id = 'l6-stage-f-password-hashing-bearer-auth';
UPDATE lessons SET order_index = 2, display_no = '6.1' WHERE id = 'l6-security-auth-owasp';
UPDATE lessons SET order_index = 3, display_no = '6.2' WHERE id = 'l6-oauth2-oidc-rbac-abac';

UPDATE lessons SET order_index = 1, display_no = '7.0' WHERE id = 'l7-stage-g-table-driven-tests-httptest';
UPDATE lessons SET order_index = 2, display_no = '7.1' WHERE id = 'l7-testing-fuzzing-benchmarks';
UPDATE lessons SET order_index = 3, display_no = '7.2' WHERE id = 'l7-integration-testcontainers-ci';

UPDATE lessons SET order_index = 1, display_no = '8.0' WHERE id = 'l8-stage-h-handler-service-repo-layers';
UPDATE lessons SET order_index = 2, display_no = '8.1' WHERE id = 'l8-clean-hexagonal-ddd';
UPDATE lessons SET order_index = 3, display_no = '8.2' WHERE id = 'l8-modular-monolith-cqrs-boundaries';

UPDATE lessons SET order_index = 1, display_no = '9.0' WHERE id = 'l9-stage-i-redis-cache-aside-backoff';
UPDATE lessons SET order_index = 2, display_no = '9.1' WHERE id = 'l9-caching-queues-outbox-sagas';
UPDATE lessons SET order_index = 3, display_no = '9.2' WHERE id = 'l9-grpc-websockets-otel-tracing';

UPDATE lessons SET order_index = 1, display_no = '10.1' WHERE id = 'l10-devops-docker-k8s-production';
UPDATE lessons SET order_index = 2, display_no = '10.2' WHERE id = 'l10-reverse-proxy-cicd-rollback-dr';
UPDATE lessons SET order_index = 3, display_no = '10.3' WHERE id = 'l10-stage-j-capstone-production-blueprint';

-- Enforce strict per-level order uniqueness
CREATE UNIQUE INDEX IF NOT EXISTS idx_lessons_level_order_unique ON lessons(level_id, order_index);

-- Server-side sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
