/**
 * @project:     PL/SQL STAR SCHEMA
 * @author:      Kamil Armatys, Vlad Udovychenko
 * @date:        19/12/2016
*/

CREATE TABLE g_sesja(
  strona_id INT NOT NULL,
  plec_id INT NOT NULL,
  kraj_id INT NOT NULL,
  wiek_id INT NOT NULL,
  czas_id INT NOT NULL,
  urzadzenie_id INT NOT NULL,
  sr_czas_sesji NUMBER(10,4) DEFAULT 0 NOT NULL,
  sum_czas_sesji INT DEFAULT 0 NOT NULL,
  sum_liczba_klikniec INT DEFAULT 0 NOT NULL,
  sr_liczba_klikniec NUMBER(10, 4) DEFAULT 0 NOT NULL,
  sum_wizyt INT DEFAULT 0 NOT NULL,
  CONSTRAINT g_sesja_pk PRIMARY KEY(strona_id, plec_id, kraj_id, wiek_id, czas_id, urzadzenie_id)
);

CREATE TABLE g_strony(
  id INT NOT NULL CONSTRAINT g_strony_pk PRIMARY KEY,
  kategoria VARCHAR2(35) NOT NULL
);

CREATE TABLE g_plec(
  id INT NOT NULL CONSTRAINT g_plec_pk PRIMARY KEY,
  nazwa CHAR(1) NOT NULL
);

CREATE TABLE g_urzadzenia(
  id INT NOT NULL CONSTRAINT g_urzadzenia_pk PRIMARY KEY,
  przegladarka VARCHAR2(35) NOT NULL,
  system_op VARCHAR2(30) NOT NULL
);

CREATE TABLE g_czas(
  id INT NOT NULL CONSTRAINT g_czas_pk PRIMARY KEY,
  dzien NUMBER(2) NOT NULL,
  tydzien NUMBER(3) NOT NULL,
  miesiac NUMBER(2) NOT NULL,
  rok NUMBER(4) NOT NULL
);

CREATE TABLE g_kraj(
  id INT NOT NULL CONSTRAINT g_kraj_pk PRIMARY KEY,
  nazwa VARCHAR2(45) NOT NULL
);

CREATE TABLE g_wiek(
  int INT NOT NULL CONSTRAINT g_wiek_pk PRIMARY KEY,
  grupa_wiek CHAR(8) NOT NULL
);