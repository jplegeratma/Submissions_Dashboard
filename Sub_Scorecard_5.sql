-- 5.3

CREATE TABLE WH_COUNTS_5_3
AS

-- look for 8 month back 
SELECT 
RUN_DATE, 
CDE_ENTITY_MODEL, 
ENTITY_PIDSL, 
ENTITY_NAME, 
CLAIM_MCE, 
CLAIM_ACO_MCE, 
WH_MON, 
SUM(TOTAL_RECS) AS EIGHT_MON_RECS
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
COUNT(ENC_CLAIM_NO||ENC_CLAIM_SUFFIX) AS TOTAL_RECS
FROM (

-- core 
SELECT
--TO_DATE('20250225','YYYYMMDD') AS RUN_DATE,
CURRENT_DATE() AS RUN_DATE,
                 cw.CDE_ENTITY_MODEL, 
                 cw.ENTITY_PIDSL,
                 cw.ENTITY_NAME,
                 E.CDE_ENC_MCO AS CLAIM_MCE,
                 CASE WHEN E.CDE_ENC_ACO in('#','+','-') 
                     THEN E.CDE_ENC_MCO ELSE E.CDE_ENC_ACO END AS CLAIM_ACO_MCE,
                 ENC_CLAIM_NO,
                 ENC_CLAIM_SUFFIX,
                 TO_CHAR(DOS_FROM_DT,'YYMM') AS DOS_MON,
                 TO_CHAR(WH_FROM_DT,'YYMM') AS WH_MON
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
         DOS_MON
HAVING DOS_MON < TO_CHAR(DATEADD(month, -7, TO_DATE(WH_MON,'YYMM')),'YYMM')

ORDER BY RUN_DATE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CLAIM_MCE, CLAIM_ACO_MCE, WH_MON DESC , DOS_MON DESC

)
GROUP BY RUN_DATE, 
         CDE_ENTITY_MODEL, 
         ENTITY_PIDSL, 
         ENTITY_NAME, 
         CLAIM_MCE, 
         CLAIM_ACO_MCE, 
         WH_MON

ORDER BY RUN_DATE, CDE_ENTITY_MODEL, ENTITY_PIDSL, ENTITY_NAME, CLAIM_MCE, CLAIM_ACO_MCE, WH_MON DESC
;


