ALTER TABLE assessments 
ADD COLUMN procedure_type VARCHAR(255) AFTER dominant_emotion,
ADD COLUMN health_issues TEXT AFTER procedure_type;
