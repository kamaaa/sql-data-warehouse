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

SELECT wiek.wiekod, wiek.wiekdo, sq.suma
FROM G_WIEK wiek
INNER JOIN (
  SELECT k.kategoria, w.id wid, SUM(s.sum_wizyt) suma
  FROM G_SESJA s
  INNER JOIN G_STRONA k ON s.strona_id = k.id
  INNER JOIN G_WIEK w ON s.wiek_id = w.id
  WHERE k.kategoria = '&&cat_title'
  AND w.id > 1
  AND s.sr_czas_sesji > 180
  GROUP BY w.id, k.kategoria
) sq ON sq.wid = wiek.id
ORDER BY sq.suma DESC
FETCH FIRST 3 ROWS ONLY;

-- undefine variables
UNDEFINE cat_title

CLEAR COLUMNS
SET VERIFY ON

TTITLE OFF
BTITLE OFF

SET ECHO ON