/**
 * @project:     PL/SQL STAR SCHEMA
 * @author:      Kamil Armatys, Vlad Udovychenko
 * @date:        19/12/2016
*/

CREATE TABLE g_strona(
  id INT NOT NULL CONSTRAINT g_strona_pk PRIMARY KEY,
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
  id DATE NOT NULL CONSTRAINT g_czas_pk PRIMARY KEY,
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
  id INT NOT NULL CONSTRAINT g_wiek_pk PRIMARY KEY,
  grupa_wiek CHAR(8) NOT NULL
);

CREATE TABLE g_sesja(
  strona_id INT NOT NULL CONSTRAINT g_sesja_fk_g_strona REFERENCES g_strona(id),
  plec_id INT NOT NULL CONSTRAINT g_sesja_fk_g_plec REFERENCES g_plec(id),
  kraj_id INT NOT NULL CONSTRAINT g_sesja_fk_g_kraj REFERENCES g_kraj(id),
  wiek_id INT NOT NULL CONSTRAINT g_sesja_fk_g_wiek REFERENCES g_wiek(id),
  czas_id DATE NOT NULL CONSTRAINT g_sesja_fk_g_czas REFERENCES g_czas(id),
  urzadzenie_id INT NOT NULL CONSTRAINT g_sesja_fk_g_urzadzenie REFERENCES g_urzadzenia(id),
  sr_czas_sesji NUMBER(10,4) DEFAULT 0 NOT NULL,
  sum_czas_sesji INT DEFAULT 0 NOT NULL,
  sum_liczba_klikniec INT DEFAULT 0 NOT NULL,
  sr_liczba_klikniec NUMBER(10, 4) DEFAULT 0 NOT NULL,
  sum_wizyt INT DEFAULT 0 NOT NULL
) PARTITION BY RANGE (czas_id)(
    PARTITION lt_2010 VALUES LESS THAN (TO_DATE('01-01-2010', 'dd-mm-yyyy')),
    PARTITION lt_2015 VALUES LESS THAN (TO_DATE('01-01-2015', 'dd-mm-yyyy')),
    PARTITION lt_2020 VALUES LESS THAN (TO_DATE('01-01-2020', 'dd-mm-yyyy'))
);

-- create bitmap index for fact table
CREATE BITMAP INDEX g_sesja_strona_bix ON g_sesja(strona_id) LOCAL;
CREATE BITMAP INDEX g_sesja_plec_bix ON g_sesja(plec_id) LOCAL;
CREATE BITMAP INDEX g_sesja_kraj_bix ON g_sesja(kraj_id) LOCAL;
CREATE BITMAP INDEX g_sesja_wiek_bix ON g_sesja(wiek_id) LOCAL;
CREATE BITMAP INDEX g_sesja_czas_bix ON g_sesja(czas_id) LOCAL;
CREATE BITMAP INDEX g_sesja_urzadzenie_bix ON g_sesja(urzadzenie_id) LOCAL;

-- bitmap index on web category
CREATE BITMAP INDEX g_strona_kat_bix ON g_strona(kategoria);
CREATE BITMAP INDEX g_plec_nazwa_bix ON g_plec(nazwa);

-- join bitmap index 
CREATE BITMAP INDEX g_sesja_g_strona ON g_sesja(g_strona.id)
FROM g_sesja, g_strona
WHERE g_sesja.strona_id = g_strona.id LOCAL;

COMMIT;