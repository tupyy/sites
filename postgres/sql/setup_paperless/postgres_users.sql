\connect paperless

-- Create users
CREATE USER paperless_service WITH PASSWORD :paperless_service_pwd;
GRANT CONNECT ON DATABASE paperless TO paperless_service;
GRANT core_readwrite TO paperless_service;

