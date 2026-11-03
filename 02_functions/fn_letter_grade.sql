-- Converts a numeric score (0-100) into a letter grade.
-- Invalid scores raise an error instead of returning a misleading value.
CREATE OR REPLACE FUNCTION fn_letter_grade (
  p_score IN NUMBER
) RETURN VARCHAR2
DETERMINISTIC
IS
BEGIN
  IF p_score IS NULL OR p_score < 0 OR p_score > 100 THEN
    RAISE_APPLICATION_ERROR(-20020,
      'Invalid score: ' || NVL(TO_CHAR(p_score), 'NULL') ||
      '. A score must be between 0 and 100.');
  END IF;

  RETURN CASE
           WHEN p_score >= 80 THEN 'A'
           WHEN p_score >= 70 THEN 'B'
           WHEN p_score >= 60 THEN 'C'
           WHEN p_score >= 50 THEN 'D'
           ELSE 'F'
         END;
END fn_letter_grade;
/
