-- Add profile_photo column to doctors table
ALTER TABLE doctors
ADD COLUMN profile_photo VARCHAR(255) DEFAULT NULL;
