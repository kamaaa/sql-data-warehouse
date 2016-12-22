SET SERVEROUTPUT ON;

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

SHOW ERRORS;