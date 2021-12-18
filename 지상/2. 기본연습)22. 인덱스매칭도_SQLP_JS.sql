/*
##################################################################################################################################################################################################
2021.08.01
��22)�ε�����Ī�� ȯ�漳��
##################################################################################################################################################################################################
*/

DROP TABLE SQLP_JS.T_CUST22;
CREATE TABLE SQLP_JS.T_CUST22
  (CUST_NO       VARCHAR2(7),
   CUS_NM        VARCHAR2(50),
   CUST_CD       VARCHAR2(3),
   FLAG          VARCHAR2(3),
   DIV          VARCHAR2(2),
   C1            VARCHAR2(30),
   C2            VARCHAR2(30),
   C3            VARCHAR2(30),
   C4            VARCHAR2(30),
   C5            VARCHAR2(30),
   CONSTRAINT PK_T_CUST22 PRIMARY KEY (CUST_NO)
  );

CREATE PUBLIC SYNONYM T_CUST22 FOR SQLP_JS.T_CUST22;

INSERT /*+ APPEND */ INTO T_CUST22
SELECT LPAD(TO_CHAR(ROWNUM), 7, '0')                                    CUST_NO
     , RPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 65000))), 10, '0')       CUS_NM
     , LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 200))) || '0', 3, '0')   CUST_CD
     , LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 100))) || '0', 3, '0')   FLAG
     , LPAD(TO_CHAR(ROUND(DBMS_RANDOM.VALUE(1, 10)))  || '0', 2, '0')   DIV
     , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                     C1
     , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                     C2
     , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                     C3
     , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                     C4
     , 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                     C5
FROM DUAL
CONNECT BY LEVEL <= 200000;

COMMIT;

CREATE INDEX SQLP_JS.IX_T_CUST22_01 ON SQLP_JS.T_CUST22(CUST_CD, FLAG, DIV);

EXECUTE DBMS_STATS.GATHER_TABLE_STATS('SQLP_JS', 'T_CUST22');
/*
DROP   TABLE SQLP_JS.T_�ֹ�23;
CREATE TABLE SQLP_JS.T_�ֹ�23
  (�ֹ���ȣ            VARCHAR2(8),
   �ֹ���            VARCHAR2(7),
   �ֹ���ǰ�ڵ�        VARCHAR2(3),
   �ֹ�����            VARCHAR2(8)
   );
*/

/*
##################################################################################################################################################################################################
2021.08.01
��22)�ε�����Ī�� �⺻����
##################################################################################################################################################################################################
*/
/*
PRIMARY KEY : CUST_NO
�ε���      : CUST_CD + FLAG + DIV

T_CUST22  200����
  - CUST_CD   200�� ����(001 ~ 200),  �ڵ�� �Ǽ��� ��  1���� 
  - DIV       100�� ����(001 ~ 100),  �ڵ�� �Ǽ��� ��  2����
  - FLAG      10��  ����,    �ڵ�� �Ǽ��� �� 20����

-----------------------------------------------------------------------
| Id  | Operation                   | Name           |A-Rows| Buffers |
-----------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                |   122|     296 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_CUST22       |   122|     296 |
|*  2 |   INDEX RANGE SCAN          | IX_T_CUST22_01 |   122|     174 |
-----------------------------------------------------------------------
  
�Ʒ� SQL�� ���� Ʃ�� �Ͻÿ�(�ε��� �� SQL���� ����)
*/

ALTER SESSION SET STATISTICS_LEVEL = ALL;

SELECT /*+ GATHER_PLAN_STATISTICS */
       *
  FROM T_CUST22 
 WHERE CUST_CD BETWEEN '150' AND '200' 
   AND DIV IN ('30', '40')
   AND FLAG = '160';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

/*
##################################################################################################################################################################################################
2021.07.25
��22)�ε�����Ī�� ����Ǯ��
##################################################################################################################################################################################################
*/

#����
SELECT /*+ GATHER_PLAN_STATISTICS */
       *
  FROM T_CUST22 
 WHERE CUST_CD BETWEEN '150' AND '200' 
   AND DIV IN ('30', '40')
   AND FLAG = '160';
--------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers |
--------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                |      1 |        |    125 |00:00:00.01 |     216 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_CUST22       |      1 |     28 |    125 |00:00:00.01 |     216 |
|*  2 |   INDEX SKIP SCAN           | IX_T_CUST22_01 |      1 |     28 |    125 |00:00:00.01 |      91 |
--------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("CUST_CD">='150' AND "FLAG"='160' AND "CUST_CD"<='200')
       filter(("FLAG"='160' AND INTERNAL_FUNCTION("DIV")));

#�ؼ�
INDEX : 
PK_T_CUST22    = T_CUST22(CUST_NO)
IX_T_CUST22_01 = T_CUST22(CUST_CD, FLAG, DIV)
BUFFER : Ư�̻��� x
ID : 2 -> 1 -> 0
ID 2) FROM T_CUST22 �� �ϱ� ���� IX_T_CUST22_01 �ε��� ��� ��Ƽ������.
      access CUST_CD  -> FLAG / filter FLAG -> DIV
ID 1) FROM T_CUST22       
ID 0) SELECT *

#Ǯ��
-IX_T_CUST22_01 �ε����� �÷� 3�� ��� WHERE���� �� �ִ°� OK
-IX_T_CUST22_01 �ε����� �÷� ���� ������, 1) �ش� �÷��� ������ �� 2) �ش� �÷��� ������ ���� ���� �� �پ��Ѱ�? ���÷� ������ �ĺ���ȣ �÷��� �ΰ��� ����Ѵٸ� �ĺ���ȣ�� �տ� �δ� ���� �� �����ϴ�.
-CUST_CD, DIV, FLAG�� ��� ������ ���� 200�������� �����ϴ�. ������, ���� ������ CUST_CD 200�� DIV 100�� FLAG 10���̴�.
-��, IX_T_CUST22_02(CUST_CD, DIV, FLAG)�� ����� ���?

SOL)
CREATE INDEX SQLP_JS.IX_T_CUST22_02 ON SQLP_JS.T_CUST22(CUST_CD, DIV, FLAG);

SELECT /*+ GATHER_PLAN_STATISTICS 
           INDEX(A IX_T_CUST22_02)*/
       *
  FROM T_CUST22 A
 WHERE CUST_CD BETWEEN '150' AND '200' 
   AND DIV IN ('30', '40')
   AND FLAG = '160';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

DROP INDEX SQLP_JS.IX_T_CUST22_02 ;      

#���
-----------------------------------------------------------------------------------------------------------------
| Id  | Operation                   | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
-----------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |                |      1 |        |     50 |00:00:00.01 |     121 |     71 |
|   1 |  TABLE ACCESS BY INDEX ROWID| T_CUST22       |      1 |     28 |     50 |00:00:00.01 |     121 |     71 |
|*  2 |   INDEX SKIP SCAN           | IX_T_CUST22_02 |      1 |     28 |     50 |00:00:00.01 |      71 |     71 |
-----------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("CUST_CD">='150' AND "FLAG"='160' AND "CUST_CD"<='200')
       filter(("FLAG"='160' AND INTERNAL_FUNCTION("DIV"))); #����# �̳��� ������ �� �� �ִٴ� ���� ������.

#�ٸ�Ǯ��
-���� ���̰� �ִ� IX_T_CUST22_02�� Operation�� INDEX SKIP SCAN�̴�.
-INDEX SKIP SCAN�� �ε��� ���� �÷� ������ INDEX RANGE SCAN�� �ȵǰ�, �ε��� ���� �÷����� �ٷ� �Ѿ�� ����̴�.
-�̷� ���� �ε��� ���� �÷��� �����ǰų�, �ε��� ���� �÷��� ��ġ�� ã�� �� ���� ����̴�.
-���� Ǯ�̴� �ε��� �÷� ���� ������ ���������, WHERE������ �� �÷��� ���� ������ ������� �ʾҴ�. (CUST_CD�� INDEX RANGE SCAN�ϸ鼭 ã������ �ٷ�����, �������� �ʹ� �پ������� �ڵ������� INDEX SKIP SCAN���� DIV�� FLAG�� �������� ��Ƽ������ �ؼ� ã��)
-��, IX_T_CUST22_02(FLAG, DIV, CUST_CD)�� ����� ���? : �������� ���� ����...�� �����ѵ�.. ������ ���� ������ �����ϸ� ������ ������. -> Q) ����Ǯ�� ó�� �ε����� �߰��ϰ�, CUST_CD�� ������ ��� �������� ��� FULL_SCAN��?

SOL2)
CREATE INDEX SQLP_JS.IX_T_CUST22_03 ON SQLP_JS.T_CUST22(FLAG, DIV, CUST_CD);

SELECT /*+ GATHER_PLAN_STATISTICS 
           INDEX(A IX_T_CUST22_03)*/
       *
  FROM T_CUST22 A
 WHERE CUST_CD BETWEEN '150' AND '200' 
   AND DIV IN ('30', '40')
   AND FLAG = '160';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

DROP INDEX SQLP_JS.IX_T_CUST22_03 ;  

#���
------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                |      1 |        |     50 |00:00:00.01 |      53 |      2 |
|   1 |  INLIST ITERATOR             |                |      1 |        |     50 |00:00:00.01 |      53 |      2 |
|   2 |   TABLE ACCESS BY INDEX ROWID| T_CUST22       |      1 |     28 |     50 |00:00:00.01 |      53 |      2 |
|*  3 |    INDEX RANGE SCAN          | IX_T_CUST22_03 |      1 |     28 |     50 |00:00:00.01 |       3 |      2 |
------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("FLAG"='160' AND (("DIV"='30' OR "DIV"='40')) AND "CUST_CD">='150' AND "CUST_CD"<='200');

SOL3)
CREATE INDEX SQLP_JS.IX_T_CUST22_04 ON SQLP_JS.T_CUST22(DIV, FLAG, CUST_CD);

SELECT /*+ GATHER_PLAN_STATISTICS 
           INDEX(A IX_T_CUST22_04)*/
       *
  FROM T_CUST22 A
 WHERE CUST_CD BETWEEN '150' AND '200' 
   AND DIV IN ('30', '40')
   AND FLAG = '160';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));

DROP INDEX SQLP_JS.IX_T_CUST22_04 ;  

#���
------------------------------------------------------------------------------------------------------------------
| Id  | Operation                    | Name           | Starts | E-Rows | A-Rows |   A-Time   | Buffers | Reads  |
------------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT             |                |      1 |        |     50 |00:00:00.01 |      53 |      2 |
|   1 |  INLIST ITERATOR             |                |      1 |        |     50 |00:00:00.01 |      53 |      2 |
|   2 |   TABLE ACCESS BY INDEX ROWID| T_CUST22       |      1 |     28 |     50 |00:00:00.01 |      53 |      2 |
|*  3 |    INDEX RANGE SCAN          | IX_T_CUST22_04 |      1 |     28 |     50 |00:00:00.01 |       3 |      2 |
------------------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access((("DIV"='30' OR "DIV"='40')) AND "FLAG"='160' AND "CUST_CD">='150' AND "CUST_CD"<='200');