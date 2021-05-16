\connect paperless

-- Create core device management role

CREATE ROLE core_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO core_readonly;

CREATE ROLE core_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO core_readwrite;

