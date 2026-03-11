SELECT
  'GqKaojXhPdg' AS data_set,
  TO_CHAR(CAST(obs.obs_date AS TIMESTAMP), 'YYYYMM') AS period,
  COUNT(*) AS tests_performed,
  COUNT(CASE WHEN LOWER(obs.val_string) = 'positive' THEN 1 END) AS tests_positive
FROM diagnostic_report_flat dr
JOIN observation_flat obs ON dr.result_obs_id = obs.id
JOIN (
    SELECT DISTINCT id, gender FROM patient_flat
) p ON dr.patient_id = p.id
WHERE obs.obs_date >= DATE_TRUNC('month', CAST(:#lastSyncTimestamp AS TIMESTAMP))
  AND dr.code_code = '68961-2'
GROUP BY TO_CHAR(CAST(obs.obs_date AS TIMESTAMP), 'YYYYMM')
ORDER BY period