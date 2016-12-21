/**
 * @project:     PL/SQL KA SCHEMA
 * @author:      Kamil Armatys, Vlad Udovychenko
 * @date:        19/12/2016
*/

-- tabela u¿ytkownicy
CREATE TABLE ka_uzytkownicy(
  id INT CONSTRAINT uzytkownicy_pk PRIMARY KEY,
  imie VARCHAR2(20) NOT NULL,
  nazwisko VARCHAR2(40) NOT NULL,
  haslo CHAR(50) NOT NULL,
  email VARCHAR2(40) NOT NULL,
  data_ur DATE NOT NULL,
  telefon VARCHAR2(20)
);

-- tabela serwisy
CREATE TABLE ka_serwisy(
  id INT CONSTRAINT serwisy_pk PRIMARY KEY,
  nazwa VARCHAR2(150) NOT NULL,
  opis VARCHAR2(512) DEFAULT ' ' NOT NULL,
  domena VARCHAR2(100) NOT NULL,
  branza VARCHAR2(50) NOT NULL
);

-- tabela laczaca uzytkownicy serwisy
CREATE TABLE ka_konta(
  id_uzytkownicy INT CONSTRAINT konta_fk_uzytkownicy REFERENCES ka_uzytkownicy(id),
  id_serwisy INT CONSTRAINT konta_fk_serwisy REFERENCES ka_serwisy(id),
  uprawnienia SMALLINT NOT NULL,
  CONSTRAINT konta_pk PRIMARY KEY(id_uzytkownicy, id_serwisy)
);

-- tabela sesje
CREATE TABLE ka_sesje(
  id INT CONSTRAINT sesje_pk PRIMARY KEY,
  id_serwis INT CONSTRAINT sesje_fk_serwisy REFERENCES ka_serwisy(id) ON DELETE CASCADE,
  ip VARCHAR2(15) NOT NULL,
  data_wejscia DATE DEFAULT(sysdate),
  data_wyjscia DATE NOT NULL
);

-- tabela systemy
CREATE TABLE ka_systemy(
  id INT CONSTRAINT systemy_pk PRIMARY KEY,
  system_operacyjny VARCHAR2(30) NOT NULL,
  przegladarka VARCHAR2(35) NOT NULL,
  czas_ladowania INT DEFAULT 0
);

-- tabela Ÿróda
CREATE TABLE ka_zrodla(
  id INT CONSTRAINT zrodla_pk PRIMARY KEY,
  nazwa VARCHAR2(255) NOT NULL,
  typ VARCHAR2(100) NOT NULL,
  adres VARCHAR2(255) NOT NULL,
  wyszukiwarka SMALLINT DEFAULT 0
);

CREATE TABLE ka_dane_demograficzne(
  id INT CONSTRAINT dane_demo_pk PRIMARY KEY,
  kraj VARCHAR2(30) NOT NULL,
  jezyk VARCHAR2(30) NOT NULL,
  miejscowosc VARCHAR2(45) DEFAULT ' ' NOT NULL,
  plec CHAR(1) NOT NULL
);