-- 5.3

-------------


-- 7/16/2025
-- Using MOC and ACO from cw Current


-- 5/7/25
-- Add Disposition and Claim Type


select * 
from MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3
where claim_aco_mce = 'TFT'
and wh_mon = '2412'
and cde_clm_type = 'I'
and cde_clm_disposition = 'O'
;

select sum(eight_mon_recs) recs, sum(eight_mon_paid) paid 
from MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3
where claim_aco_mce = 'TFT'
and wh_mon = '2412'
and cde_clm_type = 'I'
and cde_clm_disposition = 'V'
;


select cde_clm_type, cde_clm_disposition, sum(eight_mon_recs) recs, sum(eight_mon_paid) paid 
from MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3
where claim_aco_mce = 'TFT'
and wh_mon = '2412'
group by cde_clm_type,
cde_clm_disposition
;


-- 376,189,551.88
-- 4,245,077

select sum(eight_mon_recs) recs, sum(eight_mon_paid) paid 
from MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS
where claim_aco_mce = 'TFT'
and wh_mon = '2412'
and cde_clm_type = 'I'
and cde_clm_disposition = 'V'
;
-- 376,189,551.88
-- 4,244,656

select 4245077 - 4244656 = 421

select *
from MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS
--where claim_aco_mce = 'SWH'
--where claim_aco_mce = 'TFT'
--where claim_aco_mce = 'UHC'
where claim_aco_mce = 'BHP'
and wh_mon = '2411'
--and wh_mon = '2502'
and cde_clm_type = 'I'
and cde_clm_disposition = 'A'
;

select *
from MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3;

select * from mhdwprod.nw.nw_encounter_hist limit 3;

TRUNCATE TABLE MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3; 

--DROP TABLE MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3;

--CREATE TABLE MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3
--AS

INSERT INTO MHTEAM.DWDQ.INF_B_SUB_DASH_KPI_COUNTS_5_3

SELECT 
RUN_DATE, 
CDE_ENTITY_MODEL, 
ENTITY_PIDSL, 
ENTITY_NAME, 
CLAIM_MCE, 
CLAIM_ACO_MCE, 
WH_MON, 
CDE_CLM_TYPE,
CDE_CLM_DISPOSITION,
SUM(TOTAL_RECS) AS EIGHT_MON_RECS,
SUM(TOTAL_PAID) AS EIGHT_MON_PAID
FROM (

-- sum DOS records
SELECT 
RUN_DATE, 
CDE_ENTITY_MODEL, 
ENTITY_PIDSL, 
ENTITY_NAME, 
CLAIM_MCE, 
CLAIM_ACO_MCE, 
WH_MON, 
DOS_MON, 
CDE_CLM_TYPE,
CDE_CLM_DISPOSITION,
COUNT(ENC_CLAIM_NO||ENC_CLAIM_SUFFIX) AS TOTAL_RECS,
SUM(AMT_PAID) AS TOTAL_PAID
FROM (

-- core 
SELECT
--TO_DATE('20250225','YYYYMMDD') AS RUN_DATE,
CURRENT_DATE() AS RUN_DATE,
                 cw.CDE_ENTITY_MODEL, 
                 cw.ENTITY_PIDSL,
                 cw.ENTITY_NAME,
                 cw.MCO_CURRENT AS CLAIM_MCE,
                 CASE WHEN cw.ACO_CURRENT in('#','+','-') 
                     THEN cw.MCO_CURRENT ELSE cw.ACO_CURRENT END AS CLAIM_ACO_MCE,
                 ENC_CLAIM_NO,
                 ENC_CLAIM_SUFFIX,
                 TO_CHAR(DOS_FROM_DT,'YYMM') AS DOS_MON,
                 TO_CHAR(WH_FROM_DT,'YYMM') AS WH_MON,
                 AMT_PAID,
                 CDE_CLM_TYPE,
                 CDE_CLM_DISPOSITION
                 FROM mhdwprod.nw.nw_encounter_hist e
         left join mhteam.dwdq.INF_B_MCE_PIDSL_CROSSWALK cw on cw.mco = e.cde_enc_mco and cw.aco = e.cde_enc_aco            
         WHERE e.dos_from_dt >= '01-JAN-2022'
         AND e.IND_OFFSET = 'N'
--and E.CDE_ENC_ACO = 'BMC-BACO'

)
GROUP BY RUN_DATE, 
         CDE_ENTITY_MODEL, 
         ENTITY_PIDSL, 
         ENTITY_NAME, 
         CLAIM_MCE, 
         CLAIM_ACO_MCE, 
         WH_MON, 
         DOS_MON,
         CDE_CLM_TYPE,
         CDE_CLM_DISPOSITION
HAVING DOS_MON < TO_CHAR(DATEADD(month, -7, TO_DATE(WH_MON,'YYMM')),'YYMM')

ORDER BY RUN_DATE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CLAIM_MCE, CLAIM_ACO_MCE, WH_MON DESC , DOS_MON DESC

)
GROUP BY RUN_DATE, 
         CDE_ENTITY_MODEL, 
         ENTITY_PIDSL, 
         ENTITY_NAME, 
         CLAIM_MCE, 
         CLAIM_ACO_MCE, 
         WH_MON,
         CDE_CLM_TYPE,
         CDE_CLM_DISPOSITION
ORDER BY RUN_DATE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CLAIM_MCE, CLAIM_ACO_MCE, WH_MON DESC
;

