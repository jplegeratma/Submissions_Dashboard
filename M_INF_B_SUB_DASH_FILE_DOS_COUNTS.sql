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
