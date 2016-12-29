SET SERVEROUTPUT ON;

/**
 * @project: PL/SQL ETL
 * @author:  Kamil Armatys, Vlad Udovychenko
 * @date:    19/12/2016
*/

CREATE OR REPLACE PROCEDURE FILL_STAGGING_AREA(append BOOLEAN DEFAULT FALSE)
AS  
  -- fields
  v_session_id INT := 0;
  v_page_id    INT := 0;
  v_map_id     INT := 0;
  v_map_offset INT := 0;
  
  -- utils
  v_stats_count INT := 0;
  
  -- cursors
  CURSOR v_cursor_ka IS
    SELECT ses.id, ses.id_serwis, ses.ip, ses.data_wejscia, ses.data_wyjscia,
        sys.system_operacyjny, sys.przegladarka, dd.kraj, dd.miejscowosc, dd.plec
    FROM KA_SESJE ses
    INNER JOIN KA_SYSTEMY sys ON ses.id = sys.id
    INNER JOIN KA_DANE_DEMOGRAFICZNE dd ON ses.id = dd.id
    ORDER BY ses.id;
  
  CURSOR v_cursor_vu IS
    SELECT ses.id, ses.strona_id, ses.czas_wejscia, ses.czas_wyjscia,
      g.ip_adres, g.wiek, g.plec, lg.kraj, lg.miasto, u.przegladarka, u.system_os
    FROM VU_SESJA ses
    INNER JOIN VU_GOSC g ON ses.ID = g.ID
    INNER JOIN VU_LOKACJA_GOSCIA lg ON lg.ID = g.ID
    INNER JOIN VU_URZADZENIE u ON u.ID = g.ID
    ORDER BY ses.id;
    
  -- rows    
  v_ka_row v_cursor_ka%ROWTYPE;
  v_vu_row v_cursor_vu%ROWTYPE;
BEGIN 
  
  -- get sa_strony meta
  IF append = TRUE THEN
    SELECT NVL(MAX(id), 0)
    INTO v_page_id
    FROM SA_STRONY;
    
    SELECT NVL(MAX(id), 0)
    INTO v_session_id
    FROM SA_SESJE;
  ELSE
    DELETE FROM SA_SESJE;
    DELETE FROM SA_GOSCIE;
    DELETE FROM SA_STRONY;
    DELETE FROM SA_URZADZENIA;
    DELETE FROM SA_MAPY_KLIKOW;
    
    v_page_id    := 0;
    v_session_id := 1;
  END IF;
  
  -- copy ka sites to sa sites
  INSERT INTO SA_STRONY(id, domena, kategoria)
  SELECT (id+v_page_id), domena, branza
  FROM KA_SERWISY
  ORDER BY id;
  
  -- open ka select
  OPEN v_cursor_ka;
  
  LOOP
    FETCH v_cursor_ka INTO v_ka_row;
    EXIT WHEN v_cursor_ka%NOTFOUND;
  
    -- multiple insertion
    INSERT INTO SA_SESJE (id, strona_id, czas_wejscia, czas_wyjscia)
    VALUES(
      v_session_id,
      v_ka_row.id_serwis + v_page_id,
      v_ka_row.data_wejscia,
      v_ka_row.data_wyjscia
    );
    
    INSERT INTO SA_GOSCIE (id, ip_adres, wiek, plec, kraj, miasto)
    VALUES(
      v_session_id,
      v_ka_row.ip,
      0,
      v_ka_row.plec,
      v_ka_row.kraj,
      v_ka_row.miejscowosc
    );
    
    INSERT INTO SA_URZADZENIA (id, przegladarka, system_op)
    VALUES(
      v_session_id,
      v_ka_row.przegladarka,
      v_ka_row.system_operacyjny
    );
    
    -- increment
    v_session_id := v_session_id + 1;
  END LOOP;
  
  CLOSE v_cursor_ka;  
  
  -- COPY VU TO SA
  -- get offset
  SELECT NVL(MAX(id), 0)
  INTO v_page_id
  FROM SA_STRONY;
  
  SELECT NVL(MAX(id), 0)
  INTO v_map_id
  FROM SA_MAPY_KLIKOW;
  
  INSERT INTO SA_STRONY(id, domena, kategoria)
  SELECT (id+v_page_id), adres, kategoria
  FROM VU_STRONA;
  
  -- get session offset
  v_map_offset := v_session_id -1;
  
  -- open ka select
  OPEN v_cursor_vu;
  
  LOOP
    FETCH v_cursor_vu INTO v_vu_row;
    EXIT WHEN v_cursor_vu%NOTFOUND;
  
    -- multiple insertion
    INSERT INTO SA_SESJE (id, strona_id, czas_wejscia, czas_wyjscia)
    VALUES(
      v_session_id,
      v_vu_row.strona_id + v_page_id,
      v_vu_row.czas_wejscia,
      v_vu_row.czas_wyjscia
    );
    
    INSERT INTO SA_GOSCIE (id, ip_adres, wiek, plec, kraj, miasto)
    VALUES(
      v_session_id,
      v_vu_row.ip_adres,
      v_vu_row.wiek,
      v_vu_row.plec,
      v_vu_row.kraj,
      v_vu_row.miasto
    );
    
    INSERT INTO SA_URZADZENIA (id, przegladarka, system_op)
    VALUES(
      v_session_id,
      v_vu_row.przegladarka,
      v_vu_row.system_os
    );
    
    -- increment
    v_session_id := v_session_id + 1;
  END LOOP;
  
  CLOSE v_cursor_vu;
  
  --  copy all click map references to session_id
  INSERT INTO SA_MAPY_KLIKOW(id, sesja_id, click_x, click_y)
  SELECT (mk.id + v_map_id) id, (mk.sesja_id + v_map_offset) sesja_id, mk.click_x, mk.click_y
  FROM VU_MAPA_KLIKOW mk
  ORDER BY mk.id;
  
  -- add stats
  SELECT COUNT(ROWID)
  INTO v_stats_count
  FROM SA_STRONY;
  
  DBMS_OUTPUT.PUT_LINE('Add '|| v_stats_count|| ' pages');
  
  SELECT COUNT(ROWID)
  INTO v_stats_count
  FROM SA_SESJE;
  
  DBMS_OUTPUT.PUT_LINE('Add '|| v_stats_count|| ' sessions');
  
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Tables moved successfully');
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('The error occured. Rollback is executed. Error message: ' || SQLERRM);
    ROLLBACK;
END FILL_STAGGING_AREA;
/

CREATE OR REPLACE PROCEDURE FILL_STAR_DIMENSION
AS
BEGIN
  -- add gender
  INSERT INTO G_PLEC (id, nazwa)
  SELECT ROWNUM as id, plec as nazwa
  FROM (
    SELECT DISTINCT plec
    FROM SA_GOSCIE
  );
  
  -- add category
  INSERT INTO G_STRONA(id, kategoria)
  SELECT ROWNUM, kategoria
  FROM (
    select DISTINCT kategoria
    FROM SA_STRONY
  );
  
  -- add country
  INSERT INTO G_KRAJ(id, nazwa)
  SELECT ROWNUM, kraj as nazwa
  FROM (
    select DISTINCT kraj
    FROM SA_GOSCIE
  );
  
  -- add devices
  INSERT ALL
  INTO G_URZADZENIA(id, typ) VALUES(1, 'Mobilne')
  INTO G_URZADZENIA(id, typ) VALUES(2, 'Stacjonarne')
  SELECT * FROM dual;
  
  -- add time
  INSERT INTO G_CZAS(id, miesiac, rok)
  SELECT TO_DATE(fulldata, 'mm/yyyy') id, miesiac, rok
  FROM (
    SELECT DISTINCT TO_CHAR(czas_wejscia, 'mm/yyyy') fulldata, TO_CHAR(czas_wejscia, 'mm') miesiac, TO_CHAR(czas_wejscia, 'yyyy') rok
    FROM SA_SESJE
    ORDER BY TO_CHAR(czas_wejscia, 'yyyy'), TO_CHAR(czas_wejscia, 'mm')
  );
  
  -- add age group
  INSERT ALL
    INTO G_WIEK(id, wiekod, wiekdo) VALUES (1, 0,  14)
    INTO G_WIEK(id, wiekod, wiekdo) VALUES (2, 15, 30)
    INTO G_WIEK(id, wiekod, wiekdo) VALUES (3, 31, 46)
    INTO G_WIEK(id, wiekod, wiekdo) VALUES (4, 47, 62)
    INTO G_WIEK(id, wiekod, wiekdo) VALUES (5, 63, 999)
  SELECT * FROM dual;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Measure tables fill uccessfully');
END FILL_STAR_DIMENSION;
/

CREATE OR REPLACE PROCEDURE FILL_STAR_FACTS (timeInterval VARCHAR2 DEFAULT 'MONTH')
AS
BEGIN
  INSERT INTO G_SESJA (czas_id, kraj_id, wiek_id, strona_id, urzadzenie_id, plec_id, sum_wizyt, sr_czas_sesji, sum_czas_sesji, sum_liczba_klikniec, sr_liczba_klikniec)
  SELECT TRUNC(sesje.czas_wejscia, timeInterval) AS czas_id, goscie.krajid AS kraj_id, goscie.wiekid AS wiek_id, strony.katid AS strona_id, sesje.urzadzenieid AS urzadzenie_id, goscie.plec_id AS plec_id,
   COUNT(sesje.id) AS sum_wizyt, AVG(sesje.dl_sesji) AS sr_czas_sesji, SUM(sesje.dl_sesji) AS sum_czas_sesji,
   NVL(SUM(mapy_klikow.sumy), -1) AS sum_liczba_klikniec, NVL(AVG(mapy_klikow.sumy), -1) AS sr_liczba_klikniec
  FROM (
    SELECT s.id, s.strona_id, s.czas_wejscia, ROUND(24 * 60 * 60 * (s.czas_wyjscia - s.czas_wejscia)) dl_sesji, (CASE WHEN u.system_op IN('Android', 'iOS') THEN 1 ELSE 2 END) urzadzenieid
    FROM SA_SESJE s
    INNER JOIN SA_URZADZENIA u ON s.id = u.id
  ) sesje 
  INNER JOIN (
    SELECT str.id, str2.id katid
    FROM SA_STRONY str
    INNER JOIN G_STRONA str2 USING (kategoria)
  ) strony ON strony.id = sesje.strona_id
  INNER JOIN (
    SELECT g.id, k.id krajid, w.id wiekid, (CASE WHEN g.plec = 'k' THEN 1 ELSE 2 END) plec_id
    FROM SA_GOSCIE g
    INNER JOIN G_KRAJ k ON g.kraj = k.nazwa
    INNER JOIN G_WIEK w ON g.wiek BETWEEN w.wiekod AND w.wiekdo
  ) goscie ON sesje.id = goscie.id
  LEFT JOIN (
    SELECT mk.sesja_id id, COUNT(mk.sesja_id) sumy
    FROM SA_MAPY_KLIKOW mk
    GROUP BY mk.sesja_id
  ) mapy_klikow ON sesje.id = mapy_klikow.id
  GROUP BY TRUNC(sesje.czas_wejscia, timeInterval), goscie.krajid, goscie.wiekid, strony.katid, sesje.urzadzenieid, goscie.plec_id;
  
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Fact table fill uccessfully');
  
END FILL_STAR_FACTS;
/

SHOW ERRORS;