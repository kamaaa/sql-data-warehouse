/**
 * @project:     PL/SQL STAGING AREA SCHEMA
 * @author:      Kamil Armatys, Vlad Udovychenko
 * @date:        19/12/2016
*/
CREATE TABLE sa_strony (
  id INT CONSTRAINT sa_strony_pk PRIMARY KEY,
  domena VARCHAR2(100) NOT NULL,
  kategoria VARCHAR2(50) NOT NULL
);

CREATE TABLE sa_sesje (
  id INT CONSTRAINT sa_sesje_pk PRIMARY KEY,
  strona_id INT CONSTRAINT sa_sesje_fk_sa_strony REFERENCES sa_strony(id),
  czas_wejscia DATE NOT NULL,
  czas_wyjscia DATE NOT NULL
);

CREATE TABLE sa_mapy_klikow (
  id INT CONSTRAINT sa_mapy_klikow_pk PRIMARY KEY,
  sesja_id INT CONSTRAINT sa_mapyklikow_fk_sa_sesje REFERENCES sa_sesje(id),
  click_x NUMBER(4,0) NOT NULL,
  click_y NUMBER(4,0) NOT NULL
);

CREATE TABLE sa_goscie (
  id INT CONSTRAINT sa_goscie_pk PRIMARY KEY,
  ip_adres VARCHAR2(16) NOT NULL,
  wiek NUMBER(3,0) DEFAULT 0 NOT NULL,
  plec CHAR(1) DEFAULT 'm' NOT NULL,
  kraj VARCHAR2(45) NOT NULL,
  miasto VARCHAR2(45) NOT NULL,
  jezyk VARCHAR2(30)
);

CREATE TABLE sa_urzadzenia(
  id INT CONSTRAINT sa_urzadzenia_pk PRIMARY KEY,
  przegladarka VARCHAR2(35) NOT NULL,
  system_op VARCHAR(30) NOT NULL
);