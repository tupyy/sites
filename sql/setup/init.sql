-- Create resource admin user to avoid using postres admin role
CREATE USER resources_admin WITH CREATEDB CREATEROLE PASSWORD :resources_admin_pwd;
GRANT resources_admin TO postgres;

