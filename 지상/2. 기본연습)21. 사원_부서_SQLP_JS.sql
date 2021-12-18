/*
##################################################################################################################################################################################################
2021.07.25
��21)���_�μ� ȯ�漳��
##################################################################################################################################################################################################
*/
drop table SQLP_JS.t_emp;
create table SQLP_JS.t_emp 
  (emp_no      varchar2(5),
   emp_name    varchar2(50),
   dept_code   varchar2(2),
   div_code    varchar2(2)       
   );

create public synonym t_emp for SQLP_JS.t_emp;

alter table SQLP_JS.t_emp
add constraint pk_t_emp primary key(emp_no)
using index;

insert /*+ append */ into t_emp
select  lpad(trim(to_char(rownum)), 5, '0') emp_no
      , '12345678901234567890123456789012345678901234567890' emp_name
      , lpad(to_char(round(dbms_random.value(1, 99))), 2, '0') dept_code
      , lpad(to_char(round(dbms_random.value(2, 99))), 2, '0') div_code
from dual connect by level <= 99999;

COMMIT;

UPDATE T_EMP
SET DIV_CODE = '01'
WHERE EMP_NO <= '00010';

SELECT * FROM T_EMP WHERE EMP_NO <= '00010';  
SELECT * FROM T_EMP WHERE DIV_CODE = '01';

commit;

drop table SQLP_JS.t_dept;

create table SQLP_JS.t_dept
 (
  dept_code   varchar2(2),
  dept_name   varchar2(50),
  loc         varchar2(2)
);

create public synonym t_dept for SQLP_JS.t_dept;

alter table SQLP_JS.t_dept
add constraint pk_t_dept primary key(dept_code)
using index;

insert /*+ append */ into t_dept
select lpad(trim(to_char(rownum)), 2, '0') dept_code
     , lpad(trim(to_char(rownum)), 2, '0') dept_name
     , lpad(to_char(round(dbms_random.value(1, 10))), 2, '0') loc
from dual connect by level <= 99;

commit;

SELECT * FROM T_DEPT;

EXECUTE DBMS_STATS.GATHER_TABLE_STATS('SQLP_JS', 'T_EMP');
EXECUTE DBMS_STATS.GATHER_TABLE_STATS('SQLP_JS', 'T_DEPT');
/*
##################################################################################################################################################################################################
2021.07.25
��21)���_�μ� �⺻����
##################################################################################################################################################################################################
*/
/*  ���̺� 
       - ��� (��10����), �μ�(100��)

    INDEX 
       - ���PK : EMP_NO   
       - �μ�PK : DEPT_CODE

�Ʒ� SQL�� Ʃ�� �ϼ���.

  ���� 1) E.DIV_CODE='01'�� ��� : 10��,   D.LOC='01'�� ��� 30��
  ���� 2) E.DIV_CODE='01'�� ��� : 100��,   D.LOC='01'�� ��� 3��


*/
SELECT E.*
  FROM T_EMP E
 WHERE E.DIV_CODE = '01';

SELECT D.*
  FROM T_DEPT D
 WHERE D.LOC = '01';

UPDATE T_DEPT D
   SET D.LOC = '01'
 WHERE D.DEPT_CODE = '11';
 
COMMIT;

SELECT  /*+ GATHER_PLAN_STATISTICS 
            ORDERED USE_NL(D) */
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE,  
        D.DEPT_CODE,  D.DEPT_NAME,  D.LOC
FROM  T_EMP  E,  T_DEPT  D
WHERE D.DEPT_CODE   = E.DEPT_CODE;
 AND  E.DIV_CODE    = '01' 
 AND  D.LOC         = '01';

select * from table(dbms_xplan.display_cursor(null,null, 'allstats last'));

/*
--------------------------------------------------------------------
| Id  | Operation                    | Name      |A-Rows | Buffers |
--------------------------------------------------------------------
|   0 | SELECT STATEMENT             |           |     1 |     965 |
|   1 |  NESTED LOOPS                |           |     1 |     965 |
|   2 |   NESTED LOOPS               |           |    10 |     955 |
|*  3 |    TABLE ACCESS FULL         | T_EMP     |    10 |     950 |
|*  4 |    INDEX UNIQUE SCAN         | PK_T_DEPT |    10 |       5 |
|*  5 |   TABLE ACCESS BY INDEX ROWID| T_DEPT    |     1 |      10 |
--------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - filter("E"."DIV_CODE"='01')
   4 - access("D"."DEPT_CODE"="E"."DEPT_CODE")
   5 - filter("D"."LOC"='01')
*/

/*
##################################################################################################################################################################################################
2021.07.25
��21)���_�μ� ����Ǯ��
##################################################################################################################################################################################################
*/

#����
SELECT  /*+ GATHER_PLAN_STATISTICS 
            ORDERED USE_NL(D) */
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE,  
        D.DEPT_CODE,  D.DEPT_NAME,  D.LOC
FROM  T_EMP  E,  T_DEPT  D
WHERE D.DEPT_CODE   = E.DEPT_CODE
 AND  E.DIV_CODE    = '01' 
 AND  D.LOC         = '01';

#�ؼ�
INDEX : E.EMP_NO , D.DEPT_CODE
ORDER : ����̺� E, �̳� D

FROM E : �ʿ��� E�� �������� ����.
- E�� DIV_CODE �̿�? -> E.DIV_CODE = '01' ������ �� �ֳ�? -> �ش� INDEX ����. �Ұ�.
- E�� EMP_NO �̿�? -> WHERE������ ��� �ȵ� -> FULL_CSAN �� ����
- D�� PK_T_DEPT(DEPT_CODE) �̿�? -> JOIN���� E.DEPT_CODE = D.DEPT_CODE ������ (O)
WHERE E : E�� �������鼭 FILTER
- E.DIV_CODE = '01'
������ �м� :
- ���� �ε��� ȿ�� -> �ʿ信 ���� ȿ����, �ε����� ���� �߰��� �� ������ ������. (��Ƽ���� ������ ȿ��?)
- PK_T_DEPT(DEPT_CODE)�� ����̺����� �ΰ�, T_EMP�� NL�� ã�⿡ ȿ�������� ����(TALBE ACCESS FULL) -> INDEX�� T_EMP(E.DEPT_CODE)�� �δ� ���� ��õ #Ʋ��#����̺� ��ġ �ݴ��Ӥ���#
- ���ʿ� T_EMP(E.DIV_CODE) INDEX�� ������ �־��ٸ�?

FROM D : �ʿ��� D�� �������� ����.
- D�� LOC �̿�? -> D.LOC = '01' ������ �� �ֳ�? -> �ش� INDEX ����. �Ұ�.
- D�� DEPT_CODE�̿�? -> WHERE������ ����� JOIN ���� E.DEPT_CODE = D.DEPT_CODE, ��Į�� ������ ����. -> FULL_SCAN�� ���� -> TABLE ACCESS BY INDEX ROWID #
WHERE D : D�� �������鼭 FILTER
- D.LOC = '01'
������ �м� :
- ���ʿ� T_DEPT(D.LOC) INDEX�� ������ �־��ٸ�?


#Ǯ��
���� 1) E.DIV_CODE='01'�� ��� : 10��,   D.LOC='01'�� ��� 30��
- E�� ����� �� �����Ƿ� ����̺� ���̺� ���� ����
- FROM E�� ����� ���͸� �����ϰ� �� ���� ���� �� �ֵ���, INDEX�� T_EMP(E.DEPT_CODE)�� �߰�.
- FROM D�� ����� ���͸� �����ϰ� �� ���� ���� �� �ֵ���, INDEX�� T_DEPT(D.LOC)�� �߰�. + �̳� ���̺������� JOIN�� ���� INDEX KEY�� D.DEPT_CODE �߰�

SOL);
CREATE INDEX SQLP_JS.IX_T_EMP_01 ON SQLP_JS.T_EMP(DEPT_CODE);
CREATE INDEX SQLP_JS.IX_T_DEPT_01 ON SQLP_JS.T_DEPT(DEPT_CODE, LOC);

SELECT  /*+ GATHER_PLAN_STATISTICS 
            ORDERED USE_NL(D) INDEX(E IX_T_EMP_01) INDEX(D IX_T_DEPT_01)*/
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE,  
        D.DEPT_CODE,  D.DEPT_NAME,  D.LOC
FROM  T_EMP  E,  T_DEPT  D
WHERE D.DEPT_CODE   = E.DEPT_CODE
 AND  E.DIV_CODE    = '01' 
 AND  D.LOC         = '01';

select * from table(dbms_xplan.display_cursor(null,null, 'allstats last'));

DROP INDEX SQLP_JS.IX_T_EMP_01 ;
DROP INDEX SQLP_JS.IX_T_DEPT_01 ;

���� 2) E.DIV_CODE='01'�� ��� : 100��,   D.LOC='01'�� ��� 3��
- D�� ����� �� �����Ƿ� ����̺� ���� ���� -> D E
- FROM D�� ����� ���͸� �����ϰ� �� ���� ���� �� �ֵ���, INDEX�� T_DEPT(D.LOC)�� �߰�.
- FROM E�� ����� ���͸� �����ϰ� �� ���� ���� �� �ֵ���, INDEX�� T_EMP(E.DIV_CODE)�� �߰�. + �̳� ���̺������� JOIN�� ���� INDEX KEY�� E.DEPT_CODE �߰�

SOL);
CREATE INDEX SQLP_JS.IX_T_DEPT_02 ON SQLP_JS.T_DEPT(LOC);
CREATE INDEX SQLP_JS.IX_T_EMP_02 ON SQLP_JS.T_EMP(DEPT_CODE, DIV_CODE);

SELECT  /*+ GATHER_PLAN_STATISTICS 
            LEADING(D E) USE_NL(E) INDEX(E IX_T_EMP_02) INDEX(D IX_T_DEPT_02)*/
        E.EMP_NO,  E.EMP_NAME,  E.DIV_CODE,  
        D.DEPT_CODE,  D.DEPT_NAME,  D.LOC
FROM  T_EMP  E,  T_DEPT  D
WHERE D.DEPT_CODE   = E.DEPT_CODE
 AND  E.DIV_CODE    = '01' 
 AND  D.LOC         = '01';

select * from table(dbms_xplan.display_cursor(null,null, 'allstats last'));

DROP INDEX SQLP_JS.IX_T_EMP_02 ;
DROP INDEX SQLP_JS.IX_T_DEPT_02 ;


# ����?
1)
   AND  E.DIV_CODE    = '01' 
   AND  D.LOC         = '01';
   �� ������ ���� ���� ������ �� �� BUFFER�� ����?
2)
  ����1���� Ǯ�� ��...? ��������..?

*/
