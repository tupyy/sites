-- Create resource admin user to avoid using postres admin role
CREATE USER resources_admin WITH CREATEDB CREATEROLE PASSWORD :resources_admin_pwd;
GRANT resources_admin TO postgres;

-- Create databases and remove default permissions on public schema to ensure readonly permissions
-- are well applied 
CREATE DATABASE paperless OWNER resources_admin;
REVOKE ALL ON DATABASE paperless FROM PUBLIC;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
