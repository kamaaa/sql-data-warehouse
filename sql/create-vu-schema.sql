/**
 * @project:     PL/SQL VU SCHEMA
 * @author:      Kamil Armatys, Vlad Udovychenko
 * @date:        19/12/2016
*/

CREATE TABLE vu_uzytkownik (
  id INT CONSTRAINT uzytkownik_pk PRIMARY KEY,
  imie VARCHAR2(45) NOT NULL,
  nazwisko VARCHAR2(45) NOT NULL,
  haslo CHAR(45) NOT NULL,
  kraj VARCHAR2(45) NOT NULL,
  miasto VARCHAR2(45) NOT NULL
);

CREATE TABLE vu_strona (
  id INT CONSTRAINT strona_pk PRIMARY KEY,
  uzytkownik_id INT CONSTRAINT strona_fk_uzytkownik REFERENCES vu_uzytkownik(id),
  nazwa VARCHAR2(45) NOT NULL,
  adres VARCHAR2(100) NOT NULL,
  kategoria VARCHAR2(50) NOT NULL
);

CREATE TABLE vu_sesja (
  id INT CONSTRAINT sesja_pk PRIMARY KEY,
  strona_id INT CONSTRAINT sesja_fk_strona REFERENCES vu_strona(id) ON DELETE CASCADE,
  czas_wejscia DATE NOT NULL,
  czas_wyjscia DATE NOT NULL
);

CREATE TABLE vu_mapa_klikow (
  id INT CONSTRAINT mapa_klikow_pk PRIMARY KEY,
  sesja_id INT CONSTRAINT mapaklikow_fk_sesja REFERENCES vu_sesja(id) ON DELETE CASCADE,
  click_x NUMBER(4,0) NOT NULL,
  click_y NUMBER(4,0) NOT NULL
);

CREATE TABLE vu_gosc (
  id INT CONSTRAINT gosc_pk PRIMARY KEY,
  ip_adres VARCHAR2(16) NOT NULL,
  wiek NUMBER(3,0) DEFAULT 0 NOT NULL,
  plec CHAR(1) DEFAULT 'm' NOT NULL
);

CREATE TABLE vu_lokacja_goscia (
  id INT CONSTRAINT lokacja_goscia_pk PRIMARY KEY,
  kraj VARCHAR2(45) NOT NULL,
  miasto VARCHAR2(45) NOT NULL
);

CREATE TABLE vu_urzadzenie (
  id INT CONSTRAINT urzadzenie_pk PRIMARY KEY,
  przegladarka VARCHAR2(30) NOT NULL,
  system_os VARCHAR2(30) NOT NULL
);