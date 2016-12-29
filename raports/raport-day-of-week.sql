SET ECHO OFF
SET VERIFY OFF

/**
 * @project: Raport for SQL*Plus
 * @author:  Kamil Armatys
 * @data:    28/12/2016
*/

TTITLE LEFT 'Data utworzenia: ' _DATE CENTER 'Utworzyl: ' SQL.USER RIGHT 'Strona ' FORMAT 999 SQL.PNO SKIP 2
BTITLE LEFT 'Copyright (c) Kamil Armatys, Vlad Udovychenko' RIGHT 'Strona ' FORMAT 999 SQL.PNO

-- set format
SET PAGESIZE 15
COLUMN "DZIEN TYGODNIA" FORMAT a15

-- define variables
ACCEPT cat_title CHAR PROMPT 'Nazwa kategorii: '

SELECT TO_CHAR(s.czas_id, 'Day', 'NLS_DATE_LANGUAGE = Polish') "DZIEN TYGODNIA", SUM(s.sum_wizyt) suma
FROM G_SESJA s
INNER JOIN G_STRONA k ON s.strona_id = k.id
WHERE UPPER(k.kategoria) = UPPER('&&cat_title')
GROUP BY TO_CHAR(s.czas_id, 'Day', 'NLS_DATE_LANGUAGE = Polish')
ORDER BY SUM(s.sum_wizyt) DESC;

-- undefine variables
UNDEFINE cat_title

CLEAR COLUMNS
SET VERIFY ON

TTITLE OFF
BTITLE OFF

SET ECHO ON