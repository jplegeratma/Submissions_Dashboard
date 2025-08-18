-- 7/16/2025
-- use crosswalk MOC and ACO

-- MCO version - no stop light

-- Add MCO calcs for MCO heatmap


DROP VIEW INF_B_SUB_DASH_WH_DOS_MCO_AVG_PCT

CREATE VIEW INF_B_SUB_DASH_WH_DOS_MCO_AVG_PCT

AS
SELECT * FROM (

SELECT t.RUN_DATE, t.DOS_MON, t.CLAIM_MCE, t.CDE_ENTITY_MODEL, t.REC_COUNT, a.AVG_RECS, a.SD_RECS,
t.REC_COUNT/(a.AVG_RECS) AS PCT_RECS
FROM (
SELECT RUN_DATE, DOS_MON, CLAIM_MCE, CDE_ENTITY_MODEL,
    SUM(RECORD_COUNT) AS REC_COUNT
FROM INF_B_SUB_DASH_WH_DOS_ACO_COUNTS
GROUP BY RUN_DATE, DOS_MON, CLAIM_MCE, CDE_ENTITY_MODEL
) AS t
INNER JOIN INF_B_SUB_DASH_WH_DOS_MCO_AVG_SD AS a ON t.RUN_DATE = a.RUN_DATE AND t.CLAIM_MCE = a.CLAIM_MCE

)

ORDER BY RUN_DATE, DOS_MON, CLAIM_MCE;

------------

DROP VIEW INF_B_SUB_DASH_WH_DOS_MCO_AVG_SD

CREATE VIEW INF_B_SUB_DASH_WH_DOS_MCO_AVG_SD

AS
SELECT RUN_DATE, CLAIM_MCE, CDE_ENTITY_MODEL, AVG(RECORD_COUNT) AVG_RECS, STDDEV (RECORD_COUNT) SD_RECS
FROM (
SELECT RUN_DATE, CLAIM_MCE, CDE_ENTITY_MODEL, DOS_MON,
    SUM(RECORD_COUNT) AS RECORD_COUNT
FROM INF_B_SUB_DASH_WH_DOS_ACO_COUNTS
GROUP BY RUN_DATE, CLAIM_MCE, CDE_ENTITY_MODEL, DOS_MON
ORDER BY RUN_DATE, CLAIM_MCE, CDE_ENTITY_MODEL, DOS_MON
)
GROUP BY RUN_DATE, CLAIM_MCE, CDE_ENTITY_MODEL
ORDER BY RUN_DATE, CLAIM_MCE;

------------
-- Averages and SD


SELECT * FROM INF_B_SUB_DASH_WH_DOS_ACO_AVG_PCT
order by CLAIM_ACO_MCE, DOS_MON
;

--DROP VIEW INF_B_SUB_DASH_WH_DOS_ACO_AVG_PCT

SELECT *
FROM INF_B_SUB_DASH_WH_DOS_ACO_AVG_PCT;

-- This is used in Tableau Heatmap Dashboard

CREATE VIEW INF_B_SUB_DASH_WH_DOS_ACO_AVG_PCT

AS
SELECT * FROM (

SELECT t.RUN_DATE, t.DOS_MON, t.CLAIM_MCE, t.CLAIM_ACO_MCE, t.CDE_ENTITY_MODEL, t.ENTITY_PIDSL, t.ENTITY_NAME, t.REC_COUNT, a.AVG_RECS, a.SD_RECS,
t.REC_COUNT/(a.AVG_RECS) AS PCT_RECS
FROM (
SELECT RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME,
    SUM(RECORD_COUNT) AS REC_COUNT
FROM INF_B_SUB_DASH_WH_DOS_ACO_COUNTS
GROUP BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME
) AS t
INNER JOIN INF_B_SUB_DASH_WH_DOS_ACO_AVG_SD AS a ON t.RUN_DATE = a.RUN_DATE AND t.CLAIM_MCE = a.CLAIM_MCE AND t.CLAIM_ACO_MCE = a.CLAIM_ACO_MCE
--ORDER BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE

)
--WHERE CLAIM_MCE = 'NHP'

ORDER BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE;


-------------------


SELECT * FROM INF_B_SUB_DASH_WH_DOS_ACO_AVG_SD
order by CLAIM_ACO_MCE
;


CREATE VIEW INF_B_SUB_DASH_WH_DOS_ACO_AVG_SD

AS
SELECT RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, AVG(RECORD_COUNT) AVG_RECS, STDDEV (RECORD_COUNT) SD_RECS
FROM (
SELECT RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, DOS_MON,
    SUM(RECORD_COUNT) AS RECORD_COUNT
FROM INF_B_SUB_DASH_WH_DOS_ACO_COUNTS
GROUP BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, DOS_MON
ORDER BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, DOS_MON
)
GROUP BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME
ORDER BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE;

SELECT *
FROM DOS_ACO_AVG_SD_6
ORDER BY CLAIM_MCE;

----------------

-- DOS and WH

select distinct e.cde_enc_mco, e.cde_enc_aco
FROM mhdwprod.nw.nw_encounter_hist e
         left join mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw on cw.mco = e.cde_enc_mco and cw.aco = e.cde_enc_aco            
         WHERE e.dos_from_dt >= '01-JAN-2022'
         and cw.ACO_CURRENT IS NULL;
         

                 cw.MCO_CURRENT AS CLAIM_MCE,
                 CASE WHEN cw.ACO_CURRENT in('#','+','-') 
                     THEN cw.MCO_CURRENT ELSE cw.ACO_CURRENT END AS CLAIM_ACO_MCE,
                 cw.CDE_ENTITY_MODEL, 
                 cw.ENTITY_PIDSL,
                 cw.ENTITY_NAME,

         

SELECT *
FROM INF_B_SUB_DASH_WH_DOS_ACO_COUNTS
where CLAIM_ACO_MCE is null;

SELECT DISTINCT RUN_DATE
FROM INF_B_SUB_DASH_WH_DOS_ACO_COUNTS;


UPDATE MHTEAM.DWDQ.INF_B_SUB_DASH_WH_DOS_ACO_COUNTS
SET RUN_DATE = TO_DATE('20250301','YYYYMMDD');  


-- This is used in Tableau Lag Triangle and Submission Source
-- and in AVG_PCT above

TRUNCATE TABLE MHTEAM.DWDQ.INF_B_SUB_DASH_WH_DOS_ACO_COUNTS;


INSERT INTO MHTEAM.DWDQ.INF_B_SUB_DASH_WH_DOS_ACO_COUNTS

SELECT RUN_DATE, WH_MON, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION, count(CDE_CLM_DISPOSITION)
FROM (
SELECT
CURRENT_DATE() AS RUN_DATE,
                 cw.MCO_CURRENT AS CLAIM_MCE,
                 CASE WHEN cw.ACO_CURRENT in('#','+','-') 
                     THEN cw.MCO_CURRENT ELSE cw.ACO_CURRENT END AS CLAIM_ACO_MCE,
                 cw.CDE_ENTITY_MODEL, 
                 cw.ENTITY_PIDSL,
                 cw.ENTITY_NAME,
                 CDE_CLM_TYPE,
                 CDE_CLM_DISPOSITION,
                 TO_CHAR(DOS_FROM_DT,'YYMM') AS DOS_MON,
                 TO_CHAR(WH_FROM_DT,'YYMM') AS WH_MON
         FROM mhdwprod.nw.nw_encounter_hist e
         left join mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw on cw.mco = e.cde_enc_mco and cw.aco = e.cde_enc_aco            
         WHERE e.dos_from_dt >= '01-JAN-2022'
         AND e.IND_OFFSET = 'N'
)
GROUP BY RUN_DATE, WH_MON, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION
ORDER BY RUN_DATE, WH_MON, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION;

SELECT * FROM WH_DOS_ACO_COUNTS_6 limit 10;

--------------

-- This is used in Tableau Submission Files

SELECT * FROM MHTEAM.DWDQ.INF_B_SUB_DASH_FILE_DOS_COUNTS 
WHERE MCO IS NULL
LIMIT 10;

select *
from mhdwprod.nw.nw_enc_statistics stat
inner join mhdwprod.nw.ods_encounter enc
on enc.md_batch_seq=stat.md_batch_seq_ods and stat.cde_enc_mco=enc.cde_enc_mco
where zip_file_name = 'hne_claims_20240809.zip';


TRUNCATE TABLE MHTEAM.DWDQ.INF_B_SUB_DASH_FILE_DOS_COUNTS;

SELECT DISTINCT RUN_DATE 
FROM MHTEAM.DWDQ.INF_B_SUB_DASH_FILE_DOS_COUNTS LIMIT 10;

UPDATE MHTEAM.DWDQ.INF_B_SUB_DASH_FILE_DOS_COUNTS
SET RUN_DATE = TO_DATE('20250301','YYYYMMDD');  

INSERT INTO MHTEAM.DWDQ.INF_B_SUB_DASH_FILE_DOS_COUNTS
SELECT 
       RUN_DATE,
       MCO,
       ACO,
       CDE_ENTITY_MODEL, 
       ENTITY_PIDSL, 
       ENTITY_NAME, 
       ID,
       FILE_NAME,
       metadata_date_created,
       date_file_processed,
       manual_override,
       Amendment,
       metadata_total_records,
       loaded_record_count,
       error_record_count,
       metadata_total_payments,
       DOS_MON,
       record_type,
       COUNT(DOS_MON) REC_COUNT
FROM (
SELECT
       RUN_DATE,
       cde_enc_mco AS MCO,
       CLAIM_ACO_MCE AS ACO,
       CDE_ENTITY_MODEL, 
       ENTITY_PIDSL, 
       ENTITY_NAME, 
       RANK() OVER (PARTITION BY cde_enc_mco ORDER BY metadata_date_created,zip_file_name,date_file_processed) ID,
       zip_file_name as FILE_NAME,
       --zip_file_created,
       metadata_date_created,
       date_file_processed,
       ind_manual_override AS manual_override,
       ind_amendment AS Amendment,
       metadata_total_records,
       loaded_record_count,
       error_record_count,
       metadata_total_payments,
       DOS_MON,
       record_type
FROM (
SELECT
CURRENT_DATE() AS RUN_DATE,

       cw.MCO AS cde_enc_mco,
       CASE WHEN cw.ACO in('#','+','-') 
            THEN cw.MCO ELSE cw.ACO END AS CLAIM_ACO_MCE,
       CDE_ENTITY_MODEL, 
       cw.ENTITY_PIDSL, 
       ENTITY_NAME,
       zip_file_name,
       metadata_date_created,
       metadata_total_records,
       loaded_record_count,
       error_record_count,
       metadata_total_payments,
       metadata_date_created as zip_file_created, 
       to_date(max(to_char(process_end_tm,'mm/dd/yyyy')) over (partition by zip_file_name), 'MM/DD/YYYY') as DATE_FILE_PROCESSED, -- as processdt2,
       ind_manual_override,
       ind_amendment,
 CASE
         WHEN md_batch_seq_scrub IS NULL THEN 'File Failed'  
            WHEN md_batch_seq_nw  IS NULL THEN 'File processed but not loaded'        
          ELSE 'Successfully Loaded'
       END
       load_status,
       cde_load_status,
       SUBSTR(From_Service_Date,3,4) AS DOS_MON,
       record_type
from mhdwprod.nw.nw_enc_statistics stat
inner join mhdwprod.nw.ods_encounter enc
on enc.md_batch_seq=stat.md_batch_seq_ods and stat.cde_enc_mco=enc.cde_enc_mco
left join mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw on cw.mco = enc.cde_enc_mco and cw.aco = enc.cde_enc_aco            
where 1=1
and metadata_date_created between 
TO_CHAR(ADD_MONTHS(TRUNC(RUN_DATE,'MONTH'), -11)) AND
TO_CHAR(LAST_DAY(TRUNC(RUN_DATE,'MONTH'))) --rolling history of 12months
) t
) u
GROUP BY
       RUN_DATE,
       MCO,
       ACO,
       CDE_ENTITY_MODEL, 
       ENTITY_PIDSL, 
       ENTITY_NAME, 
       ID,
       FILE_NAME,
       metadata_date_created,
       date_file_processed,
       manual_override,
       Amendment,
       metadata_total_records,
       loaded_record_count,
       error_record_count,
       metadata_total_payments,
       DOS_MON,
       record_type
ORDER BY RUN_DATE, mco, metadata_date_created, DOS_MON, RECORD_TYPE;


SELECT * FROM INF_B_SUB_DASH_FILE_DOS_COUNTS 
LIMIT 10;

