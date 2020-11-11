--Below are the different types of editions in the Azure SQL database.
--   BASIC EDITION
--   STANDARD EDITION
--   PREMIUM EDITION
--   GENERAL PURPOSE EDITION
--   HYPER SCALE EDITION
--   BUSINESS CRITICAL EDITION

CREATE DATABASE DemoDB (EDITION = 'standard', SERVICE_OBJECTIVE = 'S0', MAXSIZE = 500 MB);

-- If no other options are specified, the database is created on the Azure SQL Server 
-- where the CREATE DATABASE command was executed with the default configuration. 
-- i.e. the database is created with edition “General Purpose” 
-- with service objective “Gen5, 2 vCores”. 
-- The max size property is set to 32 GB

DROP DATABASE DemoDB;