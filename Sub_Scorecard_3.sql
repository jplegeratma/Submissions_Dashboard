-- March 31, 2025 
-- Tables running MH_Submissions_Dashboard6
-- Incorportating PIDSL lookup table

/*
-------------
DROP TABLE MCE_PIDSL_CROSSWALK;
TRUNCATE TABLE MCE_PIDSL_CROSSWALK;

CREATE TABLE MCE_PIDSL_CROSSWALK
(
MCE_GROUP            VARCHAR(10),
MCE_NUM              INTEGER,
CDE_ENTITY_MODEL     VARCHAR(5),
MCO                  VARCHAR(5),
MCO_CURRENT          VARCHAR(5),
ACO                  VARCHAR(20),
ACO_CURRENT          VARCHAR(20),
ENTITY_PIDSL         VARCHAR(20),
ENTITY_NAME          VARCHAR(100),
ORG                  VARCHAR(100)
);
*/

select * from MCE_PIDSL_CROSSWALK
order by MCE_NUM;

--alter table mhteam.dwdq.MCE_PIDSL_CROSSWALK rename to mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK;

--create table mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK as select * from mhteam.dwdq.MCE_PIDSL_CROSSWALK;
--drop table mhteam.dwdq.MCE_PIDSL_CROSSWALK;


-- DOS_ACO_AVG_PCT

DROP TABLE DOS_ACO_COUNTS_6;

CREATE TABLE DOS_ACO_COUNTS_6
(
RUN_DATE            DATE,
DOS_MON             VARCHAR(4),
CLAIM_MCE           VARCHAR(10),
CLAIM_ACO_MCE       VARCHAR(10),
CDE_ENTITY_MODEL    VARCHAR(10), 
ENTITY_PIDSL        VARCHAR(20),
ENTITY_NAME         VARCHAR(100),
CDE_CLM_TYPE        VARCHAR(1),
CDE_CLM_DISPOSITION VARCHAR(2),
RECORD_COUNT        INTEGER
)
AS
SELECT RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION, count(CDE_CLM_DISPOSITION)
FROM (
SELECT
CURRENT_DATE() AS RUN_DATE,
--TO_DATE('20250225','YYYYMMDD') AS RUN_DATE,
                 E.CDE_ENC_MCO AS CLAIM_MCE,
                 CASE WHEN E.CDE_ENC_ACO in('#','+','-') THEN E.CDE_ENC_MCO ELSE E.CDE_ENC_ACO END AS CLAIM_ACO_MCE,
                 cw.CDE_ENTITY_MODEL, 
                 cw.ENTITY_PIDSL,
                 cw.ENTITY_NAME,
                 CDE_CLM_TYPE,
                 CDE_CLM_DISPOSITION,
                 TO_CHAR(DOS_FROM_DT,'YYMM') AS DOS_MON
         FROM mhdwprod.nw.nw_encounter_hist e
         left join mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw on cw.mco = e.cde_enc_mco and cw.aco = e.cde_enc_aco   
         WHERE e.dos_from_dt >= '01-JAN-2020'
         AND e.IND_OFFSET = 'N'
         --AND CDE_ENC_ACO = 'BMC-BACO'

)
GROUP BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION
ORDER BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION;


SELECT * FROM DOS_ACO_COUNTS_6;

-- clean up the crosswalk
/*

select distinct cw.mco, cw.aco, e.cde_enc_mco, e.cde_enc_aco 
from mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw
left join mhdwprod.nw.nw_encounter_hist e on cw.mco = e.cde_enc_mco and cw.aco = e.cde_enc_aco
--where e.cde_enc_aco is null
order by cw.mco, cw.aco, e.cde_enc_mco, e.cde_enc_aco;

select distinct e.cde_enc_mco, e.cde_enc_aco 
from mhdwprod.nw.nw_encounter_hist e
where cde_enc_aco in ('CCC', 'NHP', 'REV', 'STW');

--'MBH' 'CCC'
--'MBH' 'REV'

select distinct e.cde_enc_mco, e.cde_enc_aco 
from mhdwprod.nw.nw_encounter_hist e
where cde_enc_mco in ('CCC', 'NHP', 'REV', 'STW');

select distinct e.cde_enc_mco, e.cde_enc_aco 
from mhdwprod.nw.nw_encounter_hist e
where cde_enc_aco like ('STEW%')

--'MBH' 'STEWARD'

select distinct e.cde_enc_mco, e.cde_enc_aco 
from mhdwprod.nw.nw_encounter_hist e
where cde_enc_mco in ('MBH')

--'MBH' 'CCC'
--'MBH' 'REV'
--'MBH' 'STEWARD'
--'MBH' 'PHACO'
--'MBH' 'MGBACO'

select * from mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK;

update mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK
set MCO_CURRENT = 'MBH'
where ACO IN ('CCC', 'STEWARD', 'REV', 'MGBACO')

update mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK
set ACO_CURRENT = 'REV'
where ACO IN ('REV')
*/

-- Averages and SD

select * from DOS_ACO_COUNTS_6 limit 10;

DROP TABLE DOS_ACO_AVG_SD_6;

CREATE TABLE DOS_ACO_AVG_SD_6
(
RUN_DATE         DATE,
CLAIM_MCE        VARCHAR(10),
CLAIM_ACO_MCE    VARCHAR(10),
CDE_ENTITY_MODEL VARCHAR(10), 
ENTITY_PIDSL     VARCHAR(20),
ENTITY_NAME      VARCHAR(100),
AVG_RECS         INTEGER,
SD_RECS          INTEGER 
)
AS
SELECT RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, AVG(RECORD_COUNT) AVG_RECS, STDDEV (RECORD_COUNT) SD_RECS
FROM (
SELECT RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, DOS_MON,
    SUM(RECORD_COUNT) AS RECORD_COUNT
FROM DOS_ACO_COUNTS_6
GROUP BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, DOS_MON
ORDER BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, DOS_MON
)
GROUP BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME
ORDER BY RUN_DATE, CLAIM_MCE, CLAIM_ACO_MCE;

SELECT *
FROM DOS_ACO_AVG_SD_6
ORDER BY CLAIM_MCE;

-- Dived months by avg

DROP TABLE DOS_ACO_AVG_PCT_6;

CREATE TABLE DOS_ACO_AVG_PCT_6
AS
SELECT * FROM (

SELECT t.RUN_DATE, t.DOS_MON, t.CLAIM_MCE, t.CLAIM_ACO_MCE, t.CDE_ENTITY_MODEL, t.ENTITY_PIDSL, t.ENTITY_NAME, t.REC_COUNT, a.AVG_RECS, a.SD_RECS,
t.REC_COUNT/(a.AVG_RECS) AS PCT_RECS,
  CASE
    WHEN t.REC_COUNT / (a.AVG_RECS) < 0.5 THEN 'RED'
    WHEN t.REC_COUNT / (a.AVG_RECS) < 0.8 THEN 'YELLOW'
    ELSE 'GREEN'
  END AS STOP_LIGHT
FROM (
SELECT RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME,
    SUM(RECORD_COUNT) AS REC_COUNT
FROM DOS_ACO_COUNTS_6
GROUP BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME
) AS t
INNER JOIN DOS_ACO_AVG_SD_6 AS a ON t.RUN_DATE = a.RUN_DATE AND t.CLAIM_MCE = a.CLAIM_MCE AND t.CLAIM_ACO_MCE = a.CLAIM_ACO_MCE
ORDER BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE

)
--WHERE CLAIM_MCE = 'NHP'

ORDER BY RUN_DATE, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE;

SELECT * FROM DOS_ACO_AVG_PCT_6
order by CLAIM_ACO_MCE, DOS_MON
;

----------------

-- DOS and WH

DROP TABLE WH_DOS_ACO_COUNTS_6;

CREATE TABLE WH_DOS_ACO_COUNTS_6
(
RUN_DATE            DATE,
WH_MON              VARCHAR(4),
DOS_MON             VARCHAR(4),
CLAIM_MCE           VARCHAR(10),
CLAIM_ACO_MCE       VARCHAR(10),
CDE_ENTITY_MODEL    VARCHAR(10), 
ENTITY_PIDSL        VARCHAR(20),
ENTITY_NAME         VARCHAR(100),
CDE_CLM_TYPE        VARCHAR(1),
CDE_CLM_DISPOSITION VARCHAR(2),
RECORD_COUNT        INTEGER
)
AS
SELECT RUN_DATE, WH_MON, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION, count(CDE_CLM_DISPOSITION)
FROM (
SELECT
--TO_DATE('20250225','YYYYMMDD') AS RUN_DATE,
CURRENT_DATE() AS RUN_DATE,
                 E.CDE_ENC_MCO AS CLAIM_MCE,
                 CASE WHEN E.CDE_ENC_ACO in('#','+','-') THEN E.CDE_ENC_MCO ELSE E.CDE_ENC_ACO END AS CLAIM_ACO_MCE,
                 cw.CDE_ENTITY_MODEL, 
                 cw.ENTITY_PIDSL,
                 cw.ENTITY_NAME,
                 CDE_CLM_TYPE,
                 CDE_CLM_DISPOSITION,
                 TO_CHAR(DOS_FROM_DT,'YYMM') AS DOS_MON,
                 TO_CHAR(WH_FROM_DT,'YYMM') AS WH_MON
         FROM mhdwprod.nw.nw_encounter_hist e
         left join mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw on cw.mco = e.cde_enc_mco and cw.aco = e.cde_enc_aco            
         WHERE e.dos_from_dt >= '01-JAN-2020'
         AND e.IND_OFFSET = 'N'
         --AND CDE_ENC_ACO = 'BMC-BACO'

)
GROUP BY RUN_DATE, WH_MON, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION
ORDER BY RUN_DATE, WH_MON, DOS_MON, CLAIM_MCE, CLAIM_ACO_MCE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CDE_CLM_TYPE, CDE_CLM_DISPOSITION;

SELECT * FROM WH_DOS_ACO_COUNTS_6 limit 10;

--------------

-- Drill through from file stats using From_Service_Date for DOS
-- From_Service_Date
--DROP TABLE FILE_DOS_COUNTS_6;
TRUNCATE TABLE FILE_DOS_COUNTS_6;

CREATE TABLE FILE_DOS_COUNTS_6
(
RUN_DATE               DATE,
MCO                    VARCHAR(10),
ACO                    VARCHAR(10),
CDE_ENTITY_MODEL       VARCHAR(10), 
ENTITY_PIDSL           VARCHAR(20),
ENTITY_NAME            VARCHAR(100),
ID                     VARCHAR(10),
FILE_NAME              VARCHAR(100),
METADATA_DATE_CREATED  DATE,
DATE_FILE_PROCESSED    DATE,
MANUAL_OVERRIDE        VARCHAR(1),
AMENDMENT              VARCHAR(1),
METADATA_TOTAL_RECORDS NUMBER(10),
LOADED_RECORD_COUNT    NUMBER(10),
ERROR_RECORD_COUNT     NUMBER(10),
METADATA_TOTAL_PAYMENTS NUMBER(15,2),
DOS_MON                VARCHAR(4),
RECORD_TYPE            VARCHAR(1),
RECORD_COUNT           NUMBER(10)
)
AS

--INSERT INTO FILE_DOS_COUNTS_6
select 
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
select
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
from (
select --distinct
CURRENT_DATE() AS RUN_DATE,
--TO_DATE('20250225','YYYYMMDD') AS RUN_DATE,
       CASE
         WHEN stat.cde_enc_mco = 'TFT' THEN 'CHA'  
         ELSE stat.cde_enc_mco
       END AS cde_enc_mco,
       CASE WHEN enc.CDE_ENC_ACO in('#','+','-') THEN enc.CDE_ENC_MCO ELSE enc.CDE_ENC_ACO END AS CLAIM_ACO_MCE,
       CDE_ENTITY_MODEL, cw.ENTITY_PIDSL, ENTITY_NAME,
       --stat.cde_enc_mco,
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
--AND stat.cde_enc_mco = 'NHP'  --MGB-MGB
--AND stat.cde_enc_mco = 'BMC'
--AND stat.cde_enc_mco = 'CHA'

and metadata_date_created between 
TO_CHAR(ADD_MONTHS(TRUNC(TO_DATE('20250331','YYYYMMDD'),'MONTH'), -5)) AND
TO_CHAR(LAST_DAY(TRUNC(TO_DATE('20250331','YYYYMMDD'),'MONTH'))) --rolling history of 6months
--order by cde_enc_mco, metadata_date_created desc
) t
) u
--where MCO = 'BMC'
group by
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
order by RUN_DATE, mco, metadata_date_created, DOS_MON, RECORD_TYPE;

SELECT * FROM FILE_DOS_COUNTS_6 LIMIT 10;



