/**
 * @project: PL/SQL DATA GENERATORS
 * @author:  Kamil Armatys
 * @date:    19/12/2016
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE GENERATE_KA_USER ( startID IN INT, len IN INT, override IN INT ) 
AS
  v_i INT := 0;
  TYPE StringArray IS VARRAY(30) OF ka_uzytkownicy.imie%TYPE;
  TYPE StringArray2 IS VARRAY(33) OF ka_uzytkownicy.nazwisko%TYPE;
  v_names StringArray;
  v_surnames StringArray2;
  v_name ka_uzytkownicy.imie%TYPE;
  v_surname ka_uzytkownicy.nazwisko%TYPE;
  v_email ka_uzytkownicy.email%TYPE;
BEGIN
  -- define name
  v_names := StringArray('adam', 'ewa', 'adrian', 'kamil', 'joanna', 'krzysztof', 'anna', 'kacper', 'grzegorz', 'maria', 'weronika', 'marcin',
  'katarzyna', 'zuzanna', 'monika', 'karolina', 'marianna', 'jozef', 'jan', 'konrad', 'janina', 'wiktoria', 'karol', 'bozena', 'marta', 'agnieszka',
  'marlena', 'elzbieta', 'michal', 'paulina');
  
  -- define surname
  v_surnames := StringArray2('nowak', 'szewczyk', 'fr¹czyk', 'piekarczyk', 'kozak', 'szymczak', 'kaczmarczyk', 'drzewo', 'mikolaj', 'panel',
  'zdenek', 'marczak', 'drozdzak', 'armatys', 'guc', 'gwiazda', 'gross', 'intel', 'stal', 'biel', 'kaczor', 'fr¹czek', 'mostowicz', 'debosz',
  'kuczara', 'kaleta', 'mosz', 'bojenko', 'czajek', 'mroz', 'lato', 'zimik', 'boniek');
  
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from ka_uzytkownicy');
    DELETE FROM ka_uzytkownicy;
  END IF;
  
  -- starting generate data
  LOOP
  EXIT WHEN v_i = len;
  
  v_name    := v_names(ROUND(DBMS_RANDOM.value(1, 30)));
  v_surname := v_surnames(ROUND(DBMS_RANDOM.value(1, 33)));
  v_email   := v_name || v_surname || '@gmail.com';
  
  INSERT INTO ka_uzytkownicy(id, imie, nazwisko, haslo, email, data_ur, telefon)
  VALUES (
    v_i + startID,
    INITCAP(v_name),
    INITCAP(v_surname),
    TO_CHAR(DBMS_RANDOM.string('U', 40)),
    v_email,
    TO_DATE(TO_CHAR(SYSDATE - NUMTOYMINTERVAL(CAST(DBMS_RANDOM.value(15, 60) AS INT), 'YEAR'),'dd/mm/yyyy'),'dd/mm/yyyy'),
    TO_CHAR(DBMS_RANDOM.value(100000000, 999999999), '999G999G999')
  );
  
  -- increment
  v_i := v_i + 1;
  END LOOP;
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
  
END GENERATE_KA_USER;
/

CREATE OR REPLACE PROCEDURE GENERATE_KA_WEBS ( startID IN INT, len IN INT, override IN INT )
AS
  TYPE StringArray IS VARRAY(13) OF KA_SERWISY.BRANZA%TYPE;
  TYPE DomainArray IS VARRAY(5) OF CHAR(3);
  v_categories StringArray;
  v_domainsEnd DomainArray;
   
  v_name KA_SERWISY.NAZWA%TYPE;
  v_desc VARCHAR2(300);
  v_category KA_SERWISY.BRANZA%TYPE;
  
  v_key INT := 0;
  v_idx INT := 0;
  v_i INT   := 0;
BEGIN
  -- define web category
  v_categories := StringArray('Motoryzacja', 'IT', 'Sztuka i rozrywka', 'Uroda i fitness', 'Ksi¹¿ki i literatura', 'Finanse', 'Gry', 'Dom i ogród',
  'Praca i edukacja', 'Nieruchomoœci', 'Sport', 'Zakupy', 'Podró¿e');
  
  -- deine domain ends
  v_domainsEnd := DomainArray('pl', 'com', 'org', 'uk', 'it');
  
  v_desc := 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vestibulum vulputate leo, interdum pretium nulla aliquam id. Aenean vel 
  turpis fermentum elit vestibulum rutrum vitae sed erat. Sed purus sapien, ultricies nec sodales sit amet, condimentum a nisi';
  
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from ka_serwisy');
    DELETE FROM ka_serwisy;
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
  
    INSERT INTO ka_serwisy (id, nazwa, opis, domena, branza)
    VALUES (
      v_i + startID,
      LOWER(v_name),
      v_desc,
      LOWER(REPLACE(v_name,' ', '-')) || '.' || v_domainsEnd(ROUND(DBMS_RANDOM.value(1,5))),
      v_category
    );
  
    v_i := v_i + 1;
  END LOOP;
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
      
END GENERATE_KA_WEBS;
/

CREATE OR REPLACE PROCEDURE GENERATE_KA_SYSTEMS (idItem IN INT, override IN INT)
AS
  TYPE StringArray IS VARRAY(10) OF VARCHAR2(35);
  v_browsers StringArray;
  v_systems StringArray;
  v_time_loading INT;
  v_item INT;
BEGIN
  -- define browsers, chrome is the most popular browser so is there two times
  v_browsers := StringArray('Firefox', 'Chrome', 'Opera', 'Chrome', 'Internet Explorer', 'MS Edge', 'Safari', 'Samsung browser');
  
  -- define systems
  v_systems  := StringArray('Windows', 'Linux', 'MacOS', 'Android', 'iOS');
  
  -- define time loading in MS
  v_time_loading := ROUND(DBMS_RANDOM.value(0, 5000));
  
  -- check if element exists
  SELECT COUNT(ROWNUM) 
  INTO v_item
  FROM ka_systemy WHERE id = idItem;
  
  IF v_item = 1 AND override = 1 THEN
    DELETE FROM ka_systemy WHERE id = idItem;
    v_item := 0;
  END IF;
  
  IF v_item = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Item with ID ' || idItem || ' already exists. Use override option to replace item');
    RETURN;
  END IF;
  
  -- add item
  INSERT INTO ka_systemy(id, system_operacyjny, przegladarka, czas_ladowania)
  VALUES(
    idItem,
    v_systems(ROUND(DBMS_RANDOM.value(1, 5))),
    v_browsers(ROUND(DBMS_RANDOM.value(1, 8))),
    v_time_loading
  );
  
  -- save changes
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
END GENERATE_KA_SYSTEMS;
/

CREATE OR REPLACE PROCEDURE GENERATE_KA_SOURCES (idItem IN INT, override IN INT)
AS
  TYPE StringArray IS VARRAY(10) OF VARCHAR2(35);
  v_searchers   StringArray;
  v_socials     StringArray;
  v_types       StringArray;
  
  v_name        ka_zrodla.nazwa%TYPE;
  v_type        ka_zrodla.typ%TYPE;
  v_address     ka_zrodla.adres%TYPE;
  
  v_is_searcher INT;
  v_item        INT;
BEGIN
  -- define searchers, google is the most popular browser so is there three times
  v_searchers := StringArray('Google', 'Bing', 'Yahoo', 'AOL', 'Google', 'Google');
  
  -- define socials
  v_socials := StringArray('Facebook', 'Twitter', 'Instagram', 'NK', 'Fotka');
  
  -- define types
  v_types := StringArray('wyszukiwarka', 'wyszukiwarka', 'bezposredni', 'media spolecznosciowe', 'media spolecznosciowe', 'odniesienie');
  
  -- check if element exists
  SELECT COUNT(ROWNUM) 
  INTO v_item
  FROM ka_zrodla WHERE id = idItem;
  
  IF v_item = 1 AND override = 1 THEN
    DELETE FROM ka_zrodla WHERE id = idItem;
    v_item := 0;
  END IF;
  
  -- if item exists and override is not set exit the procedure with message
  IF v_item = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Item with ID ' || idItem || ' already exists. Use override option to replace item');
    RETURN;
  END IF;
  
  -- prepare data
  v_type := v_types(ROUND(DBMS_RANDOM.value(1,3)));
  
  IF v_type = 'wyszukiwarka' THEN
    v_is_searcher := 1;
    v_name        := v_searchers(ROUND(DBMS_RANDOM.value(1,6)));
    v_address     := LOWER(v_name) || '.com/' || DBMS_RANDOM.string('L', 15);
    
  ELSIF v_type = 'media spolecznosciowe' THEN
    v_is_searcher := 0;
    v_name        := v_socials(ROUND(DBMS_RANDOM.value(1,5)));
    v_address     := LOWER(v_name) || '.com/' || DBMS_RANDOM.string('L', 15);
    
  ELSIF v_type = 'bezposredni' THEN
    v_is_searcher := 0;
    v_name        := ' ';
    v_address     := '/';
    
  ELSE
    v_is_searcher := 0;
    v_name        := INITCAP(DBMS_RANDOM.string('L', 10));
    v_address     := LOWER(v_name) || '.com';
  END IF;
  
  INSERT INTO ka_zrodla(id, nazwa, typ, adres, wyszukiwarka)
  VALUES(
    idItem,
    v_name,
    v_type,
    v_address,
    v_is_searcher
  );
  
  -- save changes
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
END GENERATE_KA_SOURCES;
/

CREATE OR REPLACE PROCEDURE GENERATE_KA_DEMOGRAPHICS (idItem IN INT, override IN INT)
AS
  TYPE StringArray IS VARRAY(30) OF VARCHAR2(30);
  TYPE CityArray IS VARRAY(4) OF VARCHAR2(100);
	TYPE CityMap IS TABLE OF CityArray INDEX BY VARCHAR2(10);
  
  v_cities_map CityMap;
  v_countries  StringArray;
  
  v_item INT;
  
  v_country   ka_dane_demograficzne.kraj%TYPE;
  v_lang      ka_dane_demograficzne.jezyk%TYPE;
  v_city      ka_dane_demograficzne.miejscowosc%TYPE;
  v_sex       CHAR(1);
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
  FROM ka_dane_demograficzne WHERE id = idItem;
  
  IF v_item = 1 AND override = 1 THEN
    DELETE FROM ka_dane_demograficzne WHERE id = idItem;
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
  
  -- define language
  CASE v_country
    WHEN 'Polska' THEN v_lang := 'Polski';
    WHEN 'Anglia' THEN v_lang := 'Angielski';
    WHEN 'Niemcy' THEN v_lang := 'Niemiecki';
    WHEN 'Szwecja' THEN v_lang := 'Szwecki';
    WHEN 'Francja' THEN v_lang := 'Francuski';
    WHEN 'Rosja' THEN v_lang := 'Rosyjski';
    WHEN 'USA' THEN v_lang := 'Angielski';
    WHEN 'Wlochy' THEN v_lang := 'Wloski';
    WHEN 'Hiszpania' THEN v_lang := 'Hiszpanski';
    ELSE v_lang := 'Nie okreslono';
  END CASE;
  
  -- set city
  v_city := v_cities_map(v_country)(ROUND(DBMS_RANDOM.value(1,4)));
  
  -- set person sex
  IF ROUND(DBMS_RANDOM.value(0, 1)) = 1 THEN
    v_sex := 'm';
  ELSE
    v_sex := 'k';
  END IF;
  
  -- insert data
  INSERT INTO ka_dane_demograficzne(id, kraj, jezyk, miejscowosc, plec)
  VALUES(
    idItem,
    v_country,
    v_lang,
    v_city,
    v_sex
  );
  
  -- save changes
  COMMIT;
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
END GENERATE_KA_DEMOGRAPHICS;
/

CREATE OR REPLACE PROCEDURE GENERATE_KA_ACCOUNTS (len IN INT, override IN INT)
AS
  TYPE TCURSOR IS REF CURSOR;
  v_cursor TCURSOR;
  
  v_id_user INT;
  v_id_web  INT;
  v_item    INT;
  v_i       INT  := 1;
  
  v_user_min INT := 0;
  v_user_max INT := 0;
  v_web_min  INT := 0;
  v_web_max  INT := 0;
BEGIN
  -- get user range
  OPEN v_cursor FOR
  SELECT MAX(id), MIN(id)
  FROM KA_UZYTKOWNICY;
  
  -- save results
  FETCH v_cursor INTO v_user_max, v_user_min;
  
  -- get web range
  OPEN v_cursor FOR
  SELECT MAX(id), MIN(id)
  FROM KA_SERWISY;
  
  -- save results
  FETCH v_cursor INTO v_web_max, v_web_min;
  
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from ka_konta');
    DELETE FROM ka_konta;
  END IF;
  
  -- debug
  -- DBMS_OUTPUT.PUT_LINE('v_web_min = ' || v_web_min || ' v_web_max = ' || v_web_max);
  -- DBMS_OUTPUT.PUT_LINE('v_web_min = ' || v_user_min || ' v_web_max = ' || v_user_max);
  
  LOOP
  EXIT WHEN v_i = len;
  
  -- generate keys
  v_id_web  := ROUND(DBMS_RANDOM.value(v_web_min, v_web_max));
  v_id_user := ROUND(DBMS_RANDOM.value(v_user_min, v_user_max));
  
  SELECT COUNT(ROWNUM)
  INTO v_item
  FROM ka_konta
  WHERE ID_UZYTKOWNICY = v_id_user
  AND ID_SERWISY = v_id_web;
  
  IF v_item = 0 THEN
    INSERT INTO ka_konta (id_uzytkownicy, id_serwisy, uprawnienia)
    VALUES(
      v_id_user,
      v_id_web,
      ROUND(DBMS_RANDOM.value(1,5))
    );
    
    -- increment
    v_i := v_i + 1; 
  END IF;
  END LOOP;
  
  -- save changes
  COMMIT;
  
  -- close cursor
  CLOSE v_cursor;
  
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    DBMS_OUTPUT.PUT_LINE('Item exists with this keys: (id_uzytkownicy='||v_id_user||') and (id_serwisy='||v_id_web||')
    '||' (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
    ROLLBACK;
    
END GENERATE_KA_ACCOUNTS;
/

CREATE OR REPLACE PROCEDURE GENERATE_KA_SESSIONS (startDate IN DATE, startID IN INT, len IN INT, override IN INT)
AS
  TYPE TCURSOR IS REF CURSOR;
  v_cursor TCURSOR;
  
  v_web_min    INT;
  v_web_max    INT;
  v_day        INT;
  v_time_spent INT;
  v_time_hours CHAR(8);
  v_last_day   INT;
  v_i          INT := 0;
  
  v_ip       VARCHAR2(16)     := '';
  v_id       ka_sesje.id%TYPE := 0;
  v_date_in  ka_sesje.data_wejscia%TYPE;
BEGIN
  -- get web range
  OPEN v_cursor FOR
  SELECT MAX(ID), MIN(ID)
  FROM ka_serwisy;
  
  FETCH v_cursor INTO v_web_max, v_web_min;
  
  IF v_web_max = 0 THEN
    DBMS_OUTPUT.PUT_LINE('KA_SERWISY table is empty. Fill this table before generate sessions');
    RETURN;
  END IF;
  
  -- drop data if override
  IF override = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Drop all data from ka_sesje in month: ' || TO_CHAR(startDate, 'mm/yyyy'));
    DELETE FROM ka_sesje
    WHERE TO_CHAR(data_wejscia, 'mm/yyyy') = TO_CHAR(startDate, 'mm/yyyy');
  END IF;
  
  -- prepare some data
  -- get last day from input date
  v_last_day := TO_NUMBER(TO_CHAR(LAST_DAY(startDate),'dd'));
  
  LOOP
    EXIT WHEN v_i = len;
    
    v_id := v_i + startID;
    
    -- generate time hours
    v_time_hours := ROUND(DBMS_RANDOM.value(0, 23)) || ':' || ROUND(DBMS_RANDOM.value(0, 59)) || ':' || ROUND(DBMS_RANDOM.value(0, 59));
    
    -- generate time spent in website (in seconds) - range from 0 to 10 minutes
    v_time_spent := ROUND(DBMS_RANDOM.value(1, 600));
    
    -- generate day
    v_day := ROUND(DBMS_RANDOM.value(1, v_last_day));
    
    -- create date input
    v_date_in := TO_DATE(v_day || '/' || TO_CHAR(startDate, 'mm/yyyy') || ' ' || v_time_hours, 'dd/mm/yyyy hh24:mi:ss');
    
    -- generate ip
    v_ip := '';
    FOR v_j IN 1..4 LOOP
      v_ip := v_ip || '.' || ROUND(DBMS_RANDOM.value(1, 255));
    END LOOP;
    
--    -- debug
--    DBMS_OUTPUT.PUT_LINE('v_id = ' || v_id);
--    DBMS_OUTPUT.PUT_LINE('v_time_hours = ' || v_time_hours);
--    DBMS_OUTPUT.PUT_LINE('v_time_spent = ' || v_time_spent);
--    DBMS_OUTPUT.PUT_LINE('v_day = ' || v_day);
--    DBMS_OUTPUT.PUT_LINE('v_date_in = ' || TO_CHAR(v_date_in, 'dd/mm/yyyy hh24:mi:ss'));
--    DBMS_OUTPUT.PUT_LINE('v_ip = ' || SUBSTR(v_ip, 2));
--    DBMS_OUTPUT.PUT_LINE('v_id_web = ' || ROUND(DBMS_RANDOM.value(v_web_min, v_web_max)));
--    DBMS_OUTPUT.PUT_LINE('v_date_out = ' || TO_CHAR(v_date_in + NUMTODSINTERVAL(v_time_spent, 'SECOND'), 'dd/mm/yyyy hh24:mi:ss'));
    
    -- add data
    INSERT INTO ka_sesje (id, id_serwis, ip, data_wejscia, data_wyjscia)
    VALUES(
      v_id,
      ROUND(DBMS_RANDOM.value(v_web_min, v_web_max)),
      SUBSTR(v_ip, 2), -- remove first dot
      v_date_in,
      v_date_in + NUMTODSINTERVAL(v_time_spent, 'SECOND')
    );
    
    -- generate other references data
    GENERATE_KA_SYSTEMS(v_id, override);
    GENERATE_KA_SOURCES(v_id, override);
    GENERATE_KA_DEMOGRAPHICS(v_id, override);
    
    -- increment
    v_i := v_i + 1;
  END LOOP;
  
  COMMIT;
  CLOSE v_cursor;
  
  EXCEPTION
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error stopped procedure (ROLLBACK is now execution), error message : ' || SQLERRM);
      ROLLBACK;
      
END GENERATE_KA_SESSIONS;
/

/**
 * Utils for generate data into ka database
 *
 * @param  type         VARCHAR2  Describe what we want to generate. Two possible options SITES or SESSIONS
 * @param  length       INT       Specify how much data we want to generate
 * @param  append       BOOLEAN   Optional. If true generated data will be append to exists data, otherwise all data will be deleted. Default false 
 * @param  fixedLength  BOOLEAN   Optional. If true passed length will be not change, otherwise length will be in real max-length. Default false
 * @param  date_start   DATE      Optional. For SESSIONS type only. 
 * @param  date_end     DATE      Optional. For SESSIONS type only.
 *
 * @return void
*/
CREATE OR REPLACE PROCEDURE GENERATE_KA(type IN VARCHAR2, length IN INT, append IN BOOLEAN DEFAULT FALSE, fixedLength IN BOOLEAN DEFAULT FALSE, date_start IN DATE DEFAULT NULL, date_end IN DATE DEFAULT NULL)
AS
  v_start_id INT;
  v_override INT;
  v_length   INT;
  v_st_count INT;
  
  v_current_date DATE;
BEGIN

  -- set length for elements
  IF fixedLength = FALSE THEN
    v_length := DBMS_RANDOM.value(length / 2, length);
  ELSE
    v_length := length;
  END IF;
  
  -- select what should be generated
  CASE UPPER(type)
  WHEN 'SITES' THEN
    -- generate users
    IF append = TRUE THEN
      SELECT MAX(id)
      INTO v_start_id
      FROM ka_uzytkownicy;
      
      -- disable override
      v_override := 0;
    ELSE
      -- set default start id and allow override
      CLEAR_KA('SITES');
      v_start_id := 1;
      v_override := 1;
    END IF;
    
    -- run generate procedure
    GENERATE_KA_USER(v_start_id, v_length, v_override);
    
    -- generate sites
    IF append = TRUE THEN
      SELECT MAX(id)
      INTO v_start_id
      FROM ka_serwisy;
    END IF;
    
    -- run generate procedure
    GENERATE_KA_WEBS(v_start_id, v_length * 2, v_override);
    
    -- run generate procedure
    GENERATE_KA_ACCOUNTS(v_length, v_override);
    
    -- add feedback
    SELECT COUNT(ROWID)
    INTO v_st_count
    FROM ka_uzytkownicy;
    
    DBMS_OUTPUT.PUT_LINE('Generated ' || v_st_count || ' users');
    
    SELECT COUNT(ROWID)
    INTO v_st_count
    FROM ka_serwisy;
    
    DBMS_OUTPUT.PUT_LINE('Generated ' || v_st_count || ' webs');
    
    SELECT COUNT(ROWID)
    INTO v_st_count
    FROM ka_konta;
    
    DBMS_OUTPUT.PUT_LINE('Generated ' || v_st_count || ' accounts');
    
  WHEN 'SESSIONS' THEN
    
    IF append = TRUE THEN
      SELECT MAX(id)
      INTO v_start_id
      FROM ka_sesje;
        
      -- disable override
      v_override := 0;
    ELSE
      -- we can try clear data even if procedure not complete because we can rollback transition
      -- delete all sessions
      CLEAR_KA('SESSIONS');
        
      -- set default
      v_start_id := 1;
      v_override := 1;
    END IF;
    
    IF date_end IS NULL THEN
      IF date_start IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Date start have to be defined');
        RETURN;
        ROLLBACK;
      END IF;
      
      GENERATE_KA_SESSIONS(date_start, v_start_id, v_length, v_override);
      
      -- add feedback
      SELECT COUNT(ROWID)
      INTO v_st_count
      FROM ka_sesje;
        
      DBMS_OUTPUT.PUT_LINE('Generated ' || v_st_count || ' sessions');
      RETURN;
    END IF;
    
    -- we have a data range
    v_current_date := date_start;
    
    LOOP
      -- end loop condition
      EXIT WHEN TO_CHAR(v_current_date, 'mm/yyyy') = TO_CHAR(date_end, 'mm/yyyy');
      
      -- generate sessions
      GENERATE_KA_SESSIONS(v_current_date, v_start_id, v_length, v_override);
      
      -- increment
      v_current_date := v_current_date + INTERVAL '1' MONTH;
      v_start_id := v_start_id + v_length;
      
      -- generate new length if fixed flag is not selected
      IF fixedLength = FALSE THEN
        v_length := DBMS_RANDOM.value(length / 2, length);
      ELSE
        v_length := length;
      END IF;
    END LOOP;
    
    -- add feedback
    SELECT COUNT(ROWID)
    INTO v_st_count
    FROM ka_sesje;
        
    DBMS_OUTPUT.PUT_LINE('Generated ' || v_st_count || ' sessions');
  ELSE 
    DBMS_OUTPUT.PUT_LINE('Type not recognized. Use sites or sessions keywords');
  END CASE;
  
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Fatal error: ' || SQLERRM);
    ROLLBACK;
    
END GENERATE_KA;
/

CREATE OR REPLACE PROCEDURE CLEAR_KA (type IN VARCHAR2)
AS
BEGIN
  CASE UPPER(type)
  WHEN 'SITES' THEN
    DELETE FROM ka_konta;
    DELETE FROM ka_uzytkownicy;
    DELETE FROM ka_serwisy;
  WHEN 'SESSIONS' THEN
    DELETE FROM ka_zrodla;
    DELETE FROM ka_systemy;
    DELETE FROM ka_dane_demograficzne;
    DELETE FROM ka_sesje;
  
  ELSE
    DBMS_OUTPUT.PUT_LINE('Type was not recognized. Use SITES or SESSIONS');
  END CASE;
END CLEAR_KA;
/

SHOW ERRORS;