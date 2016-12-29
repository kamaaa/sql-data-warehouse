/**
 * @project: Web warehouse
 * @author:  Kamil Armatys, Vlad Udovychenko
 * @data:    20/12/2016
*/

SET SERVEROUTPUT ON;

ALTER SESSION SET NLS_DATE_FORMAT = 'dd/mm/yyyy hh24:mi:ss';
ALTER SESSION SET STAR_TRANSFORMATION_ENABLED=true; 

EXEC GENERATE_KA('sites', 1000, FALSE, TRUE);
EXEC GENERATE_KA('sessions', 600, FALSE, FALSE, TO_DATE('01/01/2009', 'dd/mm/yyyy'), SYSDATE);

EXEC GENERATE_VU('sites', 1000, FALSE, TRUE);
EXEC GENERATE_VU('sessions', 500, FALSE, FALSE, TO_DATE('01/01/2009', 'dd/mm/yyyy'), SYSDATE);

EXEC FILL_STAGGING_AREA(FALSE);
EXEC FILL_STAR_DIMENSION();
EXEC FILL_STAR_FACTS();

-- query 1
SELECT k.kategoria, SUM(s.sum_wizyt) suma
FROM G_SESJA s
INNER JOIN G_STRONA k ON s.strona_id = k.id
INNER JOIN G_URZADZENIA u ON s.urzadzenie_id = u.id
WHERE s.czas_id BETWEEN TO_DATE('01/01/2010', 'dd/mm/yyyy') AND TO_DATE('31/12/2014', 'dd/mm/yyyy')
AND u.typ = 'Mobilne'
GROUP BY k.kategoria
ORDER BY SUM(s.sum_wizyt) DESC;

-- query 2
SELECT k.kategoria, c.rok, p.nazwa, SUM(s.sum_wizyt) suma
FROM G_SESJA s
INNER JOIN G_PLEC p ON s.plec_id = p.id
INNER JOIN G_CZAS c ON s.czas_id = c.id
INNER JOIN G_STRONA k ON s.strona_id = k.id
WHERE s.strona_id = (
  SELECT k.id
  FROM G_SESJA s
  INNER JOIN G_STRONA k ON s.strona_id = k.id
  GROUP BY k.id
  HAVING SUM(s.sum_wizyt) = (
    SELECT MAX(SUM(ses.sum_wizyt))
    FROM G_SESJA ses
    GROUP BY ses.strona_id
  )
)
GROUP BY c.rok, p.nazwa, k.kategoria
ORDER BY c.rok, SUM(s.sum_wizyt) DESC;

-- query 2.1
SELECT kategoria, rok, nazwa, suma FROM (
  SELECT k.kategoria, c.rok, p.nazwa, SUM(s.sum_wizyt) suma, RANK() OVER (PARTITION BY c.rok ORDER BY SUM(s.sum_wizyt) DESC) rank
  FROM G_SESJA s
  INNER JOIN G_PLEC p ON s.plec_id = p.id
  INNER JOIN G_CZAS c ON s.czas_id = c.id
  INNER JOIN G_STRONA k ON s.strona_id = k.id
  WHERE s.strona_id = (
    SELECT k.id
    FROM G_SESJA s
    INNER JOIN G_STRONA k ON s.strona_id = k.id
    GROUP BY k.id
    HAVING SUM(s.sum_wizyt) = (
      SELECT MAX(SUM(ses.sum_wizyt))
      FROM G_SESJA ses
      GROUP BY ses.strona_id
    )
  )
  GROUP BY c.rok, p.nazwa, k.kategoria
)
WHERE rank = 1
ORDER BY rok, suma DESC;

-- query 3
SELECT w.wiekod, w.wiekdo, SUM(s.sum_wizyt) suma
FROM G_SESJA s
INNER JOIN G_URZADZENIA u ON s.urzadzenie_id = u.id
INNER JOIN G_WIEK w ON s.wiek_id = w.id
WHERE s.wiek_id > 1
AND u.typ = 'Mobilne'
GROUP BY s.wiek_id, w.wiekod, w.wiekdo
ORDER BY SUM(s.sum_wizyt) DESC
FETCH FIRST 1 ROWS ONLY;

-- query 4
SELECT k.kategoria, ROUND(SUM(s.sum_liczba_klikniec) / SUM(s.sum_wizyt), 3) "ILOSC KLIKNIEC NA WIZYTE"
FROM G_SESJA s
INNER JOIN G_STRONA k ON s.strona_id = k.id
GROUP BY k.kategoria
ORDER BY SUM(s.sum_liczba_klikniec) / SUM(s.sum_wizyt) DESC
FETCH FIRST 1 ROWS ONLY;

-- query 5
SELECT TO_CHAR(s.czas_id, 'Day') "DZIEN TYGODNIA", SUM(s.sum_wizyt) suma
FROM G_SESJA s
INNER JOIN G_STRONA k ON s.strona_id = k.id
WHERE k.kategoria = 'Zakupy'
GROUP BY TO_CHAR(s.czas_id, 'Day')
ORDER BY SUM(s.sum_wizyt) DESC;

-- query 6
SELECT wiek.wiekod, wiek.wiekdo, sq.suma
FROM G_WIEK wiek
INNER JOIN (
  SELECT k.kategoria, w.id wid, SUM(s.sum_wizyt) suma
  FROM G_SESJA s
  INNER JOIN G_STRONA k ON s.strona_id = k.id
  INNER JOIN G_WIEK w ON s.wiek_id = w.id
  WHERE k.kategoria = 'Nieruchomoœci'
  AND w.id > 1
  AND s.sr_czas_sesji > 180
  GROUP BY w.id, k.kategoria
) sq ON sq.wid = wiek.id
ORDER BY sq.suma DESC
FETCH FIRST 3 ROWS ONLY;