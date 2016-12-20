/**
 * @project:     PL/SQL DATA GENERATORS
 * @author:      Kamil Armatys
 * @contributor: Vlad Udovychenko
 * @date:        19/12/2016
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE GENERATE_VU_USER ( startID IN INT, len IN INT, override IN INT ) 
AS
  TYPE StringArray IS VARRAY(33) OF vu_uzytkownik.imie%TYPE;
  TYPE CityArray IS VARRAY(4) OF VARCHAR2(100);
	TYPE CityMap IS TABLE OF CityArray INDEX BY VARCHAR2(10);
  
  v_cities_map CityMap;
  v_countries  StringArray;
  v_names      StringArray;
  v_surnames   StringArray;
  
  v_name    vu_uzytkownik.imie%TYPE;
  v_surname vu_uzytkownik.nazwisko%TYPE;
  v_city    vu_uzytkownik.miasto%TYPE;
  v_country vu_uzytkownik.kraj%TYPE;
  
  v_i INT := 0;
BEGIN
  -- define name
  v_names := StringArray('adam', 'ewa', 'adrian', 'kamil', 'joanna', 'krzysztof', 'anna', 'kacper', 'grzegorz', 'maria', 'weronika', 'marcin',
  'katarzyna', 'zuzanna', 'monika', 'karolina', 'marianna', 'jozef', 'jan', 'konrad', 'janina', 'wiktoria', 'karol', 'bozena', 'marta', 'agnieszka',
  'marlena', 'elzbieta', 'michal', 'paulina');
  
  -- define surname
  v_surnames := StringArray('nowak', 'szewczyk', 'fr¹czyk', 'piekarczyk', 'kozak', 'szymczak', 'kaczmarczyk', 'drzewo', 'mikolaj', 'panel',
  'zdenek', 'marczak', 'drozdzak', 'armatys', 'guc', 'gwiazda', 'gross', 'intel', 'stal', 'biel', 'kaczor', 'fr¹czek', 'mostowicz', 'debosz',
  'kuczara', 'kaleta', 'mosz', 'bojenko', 'czajek', 'mroz', 'lato', 'zimik', 'boniek');
  
  --define country
  v_countries := StringArray('Polska', 'Anglia', 'Niemcy', 'Szwecja', 'Francja', 'Rosja', 'USA', 'Wlochy', 'Hiszpania');
  
  -- define cities
  v_cities_map('Polska') := CityArray('Krakow', 'Warszawa', 'Wroclaw', 'Gdansk');
  v_cities_map('Anglia') := CityArray('Londyn', 'Manchester', 'Liverpool', 'Leeds');
  v_cities_map('Niemcy') := CityArray('Berlin', 'Hamburg', 'Dortmund', 'Hanover');
  v_cities_map('Szwecja') := CityArray('Goteborg', 'Malmo', 'Sztokholm', 'Norrkoping');
  v_cities_map('Francja') := CityArray('Paryz', 'Nantes', 'Lyon', 'Tuluza');
  v_cities_map('Rosja') := CityArray('Moskwa', 'St. Petersburg', 'Woronez', 'Smolensk');
  v_cities_map('USA') := CityArray('Nowy Jork', 'Boston', 'Waszyngton', 'Orlando');
  v_cities_map('Wlochy') := CityArray('Rzym', 'Turyn', 'Mediolan', 'Lece');
  v_cities_map('Hiszpania') := CityArray('Madryt', 'Barcelona', 'Grenada', 'Leon');
  
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from vu_uzytkownik');
    DELETE FROM vu_uzytkownik;
  END IF;
  
  -- starting generate data
  LOOP
  EXIT WHEN v_i = len;
  
  v_name    := v_names(ROUND(DBMS_RANDOM.value(1, 30)));
  v_surname := v_surnames(ROUND(DBMS_RANDOM.value(1, 33)));
  v_country := v_countries(ROUND(DBMS_RANDOM.value(1,9)));
  v_city := v_cities_map(v_country)(ROUND(DBMS_RANDOM.value(1,4)));
  
  INSERT INTO vu_uzytkownik(id, imie, nazwisko, haslo, kraj, miasto)
  VALUES (
    v_i + startID,   -- ID
    INITCAP(v_name),          -- name
    INITCAP(v_surname),       -- surname
    TO_CHAR(DBMS_RANDOM.string('U', 40)),        -- password
    v_country,
    v_city
  );
  
  -- increment
  v_i := v_i + 1;
  END LOOP;
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
  
END GENERATE_VU_USER;
/

CREATE OR REPLACE PROCEDURE GENERATE_VU_PAGES ( startID IN INT, len IN INT, override IN INT )
AS
  TYPE StringArray IS VARRAY(13) OF KA_SERWISY.BRANZA%TYPE;
  TYPE DomainArray IS VARRAY(5) OF CHAR(3);
  v_categories StringArray;
  v_domainsEnd DomainArray;
   
  v_name VU_STRONA.NAZWA%TYPE;
  v_category VU_STRONA.KATEGORIA%TYPE;
  
  v_user_min INT := 0;
  v_user_max INT := 0;
  
  v_key INT := 0;
  v_idx INT := 0;
  v_i   INT := 0;
  
  CURSOR v_cursor IS
    SELECT MAX(ID), MIN(ID)
    FROM VU_UZYTKOWNIK;
BEGIN
  -- define web category
  v_categories := StringArray('Motoryzacja', 'IT', 'Sztuka i rozrywka', 'Uroda i fitness', 'Ksi¹¿ki i literatura', 'Finanse', 'Gry', 'Dom i ogród',
  'Praca i edukacja', 'Nieruchomoœci', 'Sport', 'Zakupy', 'Podró¿e');
  
  -- deine domain ends
  v_domainsEnd := DomainArray('pl', 'com', 'org', 'uk', 'it');
  
  -- get user range id
  OPEN v_cursor;
  FETCH v_cursor INTO v_user_max, v_user_min;
  
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from vu_strona');
    DELETE FROM VU_STRONA;
  END IF;
  
  LOOP
    EXIT WHEN v_i = len;
  
    v_key      := ROUND(DBMS_RANDOM.value(1,3));
    v_category := v_categories(ROUND(DBMS_RANDOM.value(1,13)));
  
    IF (v_key = 1) THEN
      v_name := DBMS_RANDOM.string('L', 5) || ' ' || REPLACE(v_category, ' ', '');
    ELSIF (v_key = 2) THEN
      v_name := REPLACE(v_category, ' ', '') || ' ' || DBMS_RANDOM.string('L', 5);
    ELSE
      v_idx := INSTR(v_category, ' ', 1, 1);
      IF v_idx = 0 THEN
        v_idx  := LENGTH(v_category);
        v_name := SUBSTR(v_category, 1, v_idx / 2) || DBMS_RANDOM.string('L', 5) || SUBSTR(v_category, v_idx / 2, v_idx);    
      ELSE
        v_name := REPLACE(v_category, ' ', DBMS_RANDOM.string('L', 5));
      END IF;
    END IF;
  
    INSERT INTO vu_strona (id, uzytkownik_id, nazwa, adres, kategoria)
    VALUES (
      v_i + startID,
      ROUND(DBMS_RANDOM.value(v_user_min, v_user_max)),
      LOWER(v_name),
      LOWER(REPLACE(v_name,' ', '-')) || '.' || v_domainsEnd(ROUND(DBMS_RANDOM.value(1,5))),
      v_category
    );
  
    v_i := v_i + 1;
  END LOOP;
  COMMIT;
  CLOSE v_cursor;
  
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
      
END GENERATE_VU_PAGES;
/

CREATE OR REPLACE PROCEDURE GENERATE_VU_SESSIONS (startDate IN DATE, startID IN INT, len IN INT, override IN INT)
AS
  v_day        INT;
  v_time_spent INT;
  v_time_hours CHAR(8);
  v_last_day   INT;
  
  v_i          INT := 0;
  v_id         INT := 0;
  
  v_web_min    INT := 0;
  v_web_max    INT := 0;
  
  v_date_in  vu_sesja.czas_wejscia%TYPE;
  
  CURSOR v_web_cursor IS
    SELECT MAX(id), MIN(id)
    FROM vu_strona;
BEGIN
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from vu_sesja');
    DELETE FROM vu_sesja
    WHERE TO_CHAR(czas_wejscia, 'mm') = TO_CHAR(startDate, 'mm');
  END IF;
  
  -- get page id range
  OPEN v_web_cursor;
  FETCH v_web_cursor INTO v_web_max, v_web_min;
  CLOSE v_web_cursor;
  
  -- prepare some data
  -- get last day from input date
  v_last_day := TO_NUMBER(TO_CHAR(LAST_DAY(startDate),'dd'));
  
  LOOP
    EXIT WHEN v_i = len;
    
    -- generate id
    v_id := v_i + startID;
    
    -- generate time hours
    v_time_hours := ROUND(DBMS_RANDOM.value(0, 23)) || ':' || ROUND(DBMS_RANDOM.value(0, 59)) || ':' || ROUND(DBMS_RANDOM.value(0, 59));
    
    -- generate time spent in website (in seconds) - range from 0 to 10 minutes
    v_time_spent := ROUND(DBMS_RANDOM.value(1, 600));
    
    -- generate day
    v_day := ROUND(DBMS_RANDOM.value(1, v_last_day));
    
    -- create date input
    v_date_in := TO_DATE(v_day || '/' || TO_CHAR(startDate, 'mm/yyyy') || ' ' || v_time_hours, 'dd/mm/yyyy hh24:mi:ss');
    
--    -- debug
--    DBMS_OUTPUT.PUT_LINE('v_id = ' || v_id);
--    DBMS_OUTPUT.PUT_LINE('v_time_hours = ' || v_time_hours);
--    DBMS_OUTPUT.PUT_LINE('v_time_spent = ' || v_time_spent);
--    DBMS_OUTPUT.PUT_LINE('v_day = ' || v_day);
--    DBMS_OUTPUT.PUT_LINE('v_date_in = ' || TO_CHAR(v_date_in, 'dd/mm/yyyy hh24:mi:ss'));
--    DBMS_OUTPUT.PUT_LINE('v_date_out = ' || TO_CHAR(v_date_in + NUMTODSINTERVAL(v_time_spent, 'SECOND'), 'dd/mm/yyyy hh24:mi:ss'));
    
    -- add data
    INSERT INTO vu_sesja (id, strona_id, czas_wejscia, czas_wyjscia)
    VALUES(
      v_id,
      ROUND(DBMS_RANDOM.value(v_web_min, v_web_max)),
      v_date_in,
      v_date_in + NUMTODSINTERVAL(v_time_spent, 'SECOND')
    );
    
    -- generate other references data
    GENERATE_VU_GUEST(v_id, override);
    GENERATE_VU_CLICKMAP(v_id, 1, ROUND(DBMS_RANDOM.value(1, 1000)), override);
    
    -- increment
    v_i := v_i + 1;
  END LOOP;
  
  -- save changes
  COMMIT;
  
  -- catch exceptions
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
      
END GENERATE_VU_SESSIONS;
/

CREATE OR REPLACE PROCEDURE GENERATE_VU_CLICKMAP (sessionID IN INT, startID IN INT, len IN INT, override IN INT)
AS
  v_i INT := 0;

BEGIN
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from vu_mapa_klikow');
    DELETE FROM VU_MAPA_KLIKOW
    WHERE SESJA_ID = sessionID;
  END IF;
  
  LOOP
    EXIT WHEN v_i = len;
    
    -- add data
    INSERT INTO VU_MAPA_KLIKOW (id, sesja_id, click_x, click_y)
    VALUES(
      v_i + startID,
      sessionID,
      ROUND(DBMS_RANDOM.value(1, 1920)),
      ROUND(DBMS_RANDOM.value(1, 1080))
    );
    
    -- increment
    v_i := v_i + 1;
  END LOOP;
  
  -- sace changes
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
      
END GENERATE_VU_CLICKMAP;
/

CREATE OR REPLACE PROCEDURE GENERATE_VU_LOCATION (idItem IN INT, override IN INT)
AS
  TYPE StringArray IS VARRAY(30) OF VARCHAR2(30);
  TYPE CityArray IS VARRAY(4) OF VARCHAR2(100);
	TYPE CityMap IS TABLE OF CityArray INDEX BY VARCHAR2(10);
  
  v_cities_map CityMap;
  v_countries  StringArray;
  
  v_item INT;
  
  v_country   VU_LOKACJA_GOSCIA.KRAJ%TYPE;
  v_city      VU_LOKACJA_GOSCIA.MIASTO%TYPE;
BEGIN
  --define country
  v_countries := StringArray('Polska', 'Anglia', 'Niemcy', 'Szwecja', 'Francja', 'Rosja', 'USA', 'Wlochy', 'Hiszpania');
  
  -- define cities
  v_cities_map('Polska') := CityArray('Krakow', 'Warszawa', 'Wroclaw', 'Gdansk');
  v_cities_map('Anglia') := CityArray('Londyn', 'Manchester', 'Liverpool', 'Leeds');
  v_cities_map('Niemcy') := CityArray('Berlin', 'Hamburg', 'Dortmund', 'Hanover');
  v_cities_map('Szwecja') := CityArray('Goteborg', 'Malmo', 'Sztokholm', 'Norrkoping');
  v_cities_map('Francja') := CityArray('Paryz', 'Nantes', 'Lyon', 'Tuluza');
  v_cities_map('Rosja') := CityArray('Moskwa', 'St. Petersburg', 'Woronez', 'Smolensk');
  v_cities_map('USA') := CityArray('Nowy Jork', 'Boston', 'Waszyngton', 'Orlando');
  v_cities_map('Wlochy') := CityArray('Rzym', 'Turyn', 'Mediolan', 'Lece');
  v_cities_map('Hiszpania') := CityArray('Madryt', 'Barcelona', 'Grenada', 'Leon');
  
  -- check if element exists
  SELECT COUNT(ROWNUM) 
  INTO v_item
  FROM vu_lokacja_goscia WHERE id = idItem;
  
  IF v_item = 1 AND override = 1 THEN
    DELETE FROM vu_lokacja_goscia WHERE id = idItem;
    v_item := 0;
  END IF;
  
  -- if item exists and override is not set exit the procedure with message
  IF v_item = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Item with ID ' || idItem || ' already exists. Use override option to replace item');
    RETURN;
  END IF;
  
  -- prepare data
  -- get country
  v_country := v_countries(ROUND(DBMS_RANDOM.value(1,9)));
  
  -- set city
  v_city := v_cities_map(v_country)(ROUND(DBMS_RANDOM.value(1,4)));
  
  -- insert data
  INSERT INTO vu_lokacja_goscia(id, kraj, miasto)
  VALUES(
    idItem,
    v_country,
    v_city
  );
  
  -- save changes
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
END GENERATE_VU_LOCATION;
/

CREATE OR REPLACE PROCEDURE GENERATE_VU_DEVICE (idItem IN INT, override IN INT)
AS
  TYPE StringArray IS VARRAY(10) OF VARCHAR2(35);
  
  v_browsers StringArray;
  v_systems  StringArray;
  
  v_item INT := 0;
BEGIN 
  -- check if item exists
  SELECT COUNT(ROWNUM)
  INTO v_item
  FROM vu_urzadzenie
  WHERE id = idItem;
  
  IF v_item = 1 AND override = 1 THEN
    DELETE FROM vu_urzadzenie WHERE id = idItem;
    v_item := 0;
  ELSIF v_item = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Item with ID ' || idItem || ' already exists. Use override option to replace item');
    RETURN;
  END IF;
  
  -- define browsers, chrome is the most popular browser so is there two times
  v_browsers := StringArray('Firefox', 'Chrome', 'Opera', 'Chrome', 'Internet Explorer', 'MS Edge', 'Safari', 'Samsung browser');
  
  -- define systems
  v_systems  := StringArray('Windows', 'Linux', 'MacOS', 'Android', 'iOS');
  
  -- add data
  INSERT INTO vu_urzadzenie (id, przegladarka, system_os)
  VALUES(
    idItem,
    v_browsers(ROUND(DBMS_RANDOM.value(1, 8))),
    v_systems(ROUND(DBMS_RANDOM.value(1, 5)))
  );
  
  EXCEPTION 
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
    
END GENERATE_VU_DEVICE;
/

CREATE OR REPLACE PROCEDURE GENERATE_VU_GUEST (itemID IN INT, override IN INT)
AS
  v_item INT;
  
  v_ip  vu_gosc.ip_adres%TYPE;
  v_sex vu_gosc.plec%TYPE;
BEGIN
  -- check if item exists
  SELECT COUNT(ROWNUM)
  INTO v_item
  FROM vu_gosc
  WHERE id = itemID;
  
  -- drop item if exists and override falg is enable
  IF v_item = 1 AND override = 1 THEN
    DELETE FROM vu_gosc WHERE id = itemID;
    v_item := 0;
  ELSIF v_item = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Item with ID ' || itemID || ' already exists. Use override option to replace item');
    RETURN;
  END IF;
  
  -- prepare data
  -- generate sex
  IF ROUND(DBMS_RANDOM.value(0, 1)) = 1 THEN
    v_sex := 'm';
  ELSE
    v_sex := 'k';
  END IF;
  
  -- generate IP
  v_ip := '';
  FOR v_i IN 1..4 LOOP
    v_ip := v_ip || '.' || ROUND(DBMS_RANDOM.value(1, 255));
  END LOOP;
  
  -- add data
  INSERT INTO vu_gosc (id, ip_adres, wiek, plec)
  VALUES(
    itemID,
    SUBSTR(v_ip, 2), -- skip first dot
    ROUND(DBMS_RANDOM.value(15, 75)),
    v_sex
  );
  
  -- save data
  COMMIT;
  
  -- generate relative data
  GENERATE_VU_LOCATION(itemID, 0);
  GENERATE_VU_DEVICE(itemID, 0);

  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
    
END GENERATE_VU_GUEST;
/

SHOW ERRORS;