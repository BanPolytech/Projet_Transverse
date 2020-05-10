--CONFIG
SET datestyle = dmy;
SET lc_monetary = fr_FR;

------ TABLE CLIENT
drop table IF EXISTS client;
create table client(
	IDCLIENT_BRUT real primary key,
	CIVILITE varchar(10),
	DATENAISSANCE timestamp,
	MAGASIN varchar(15),
	DATEDEBUTADHESION timestamp,
	DATEREADHESION timestamp,
	DATEFINADHESION timestamp,
	VIP integer,
	CODEINSEE varchar(10),
	PAYS varchar(2)
);

COPY client FROM '/Users/Drake/Google Drive (esteban.gobert17@gmail.com)/MBA ESG/Projet Transverse/DATA_Projet_R/CLIENT.CSV' CSV HEADER DELIMITER '|' null '';

-- TRANSFORMATION
alter table client add IDCLIENT bigint;
update client set IDCLIENT = CAST(IDCLIENT_BRUT as bigint);
alter table client drop IDCLIENT_BRUT;
alter table client add primary key (IDCLIENT);

------ TABLE ENTETES TICKET
drop table IF EXISTS entetes_ticket;
create table entetes_ticket(
	IDTICKET bigint primary key,
	TIC_DATE timestamp,
	MAG_CODE varchar(10),
	IDCLIENT_BRUT real,
	TIC_TOTALTTC int
);

COPY entetes_ticket FROM '/Users/Drake/Google Drive (esteban.gobert17@gmail.com)/MBA ESG/Projet Transverse/DATA_Projet_R/ENTETES_TICKET_V4.CSV' CSV HEADER DELIMITER '|' null '';

-- TRANSFORMATION
alter table entetes_ticket add IDCLIENT bigint;
update entetes_ticket set IDCLIENT = CAST(IDCLIENT_BRUT as bigint);
alter table entetes_ticket drop IDCLIENT_BRUT;


------ TABLE LIGNES TICKET
drop table IF EXISTS lignes_ticket;
create table lignes_ticket(
	IDTICKET bigint,
	NUMLIGNETICKET numeric,
	IDARTICLE varchar(10),
	QUANTITE_BRUT varchar(10),
	MONTANTREMISE money,
	TOTAL money,
	MARGESORTIE money
);

COPY lignes_ticket FROM '/Users/Drake/Google Drive (esteban.gobert17@gmail.com)/MBA ESG/Projet Transverse/DATA_Projet_R/LIGNES_TICKET_V4.CSV' CSV HEADER DELIMITER '|' null '';

---TRANSFORMATION QUANTITE_BRUT
ALTER TABLE lignes_ticket ADD QUANTITE float;
UPDATE lignes_ticket SET QUANTITE =  CAST(REPLACE(QUANTITE_BRUT , ',', '.') AS float);
ALTER TABLE lignes_ticket DROP QUANTITE_BRUT;


----- TABLE REF_ARTICLE
drop table IF EXISTS ref_article;
create table ref_article(
	CODEARTICLE varchar(10) primary key,
	CODEUNIVERS varchar(10),
	CODEFAMILLE varchar(10),
	CODESOUSFAMILLE varchar(10)
);

COPY ref_article FROM '/Users/Drake/Google Drive (esteban.gobert17@gmail.com)/MBA ESG/Projet Transverse/DATA_Projet_R/REF_ARTICLE.CSV' CSV HEADER DELIMITER '|' null '';

----- TABLE REF_MAGASIN
drop table IF EXISTS ref_magasin;
create table ref_magasin(
	CODESOCIETE varchar(3) primary key,
	VILLE varchar(40),
	LIBELLEDEPARTEMENT smallint,
	LIBELLEREGIONCOMMERCIALE varchar(20)
);

COPY ref_magasin FROM '/Users/Drake/Google Drive (esteban.gobert17@gmail.com)/MBA ESG/Projet Transverse/DATA_Projet_R/REF_MAGASIN.CSV' CSV HEADER DELIMITER '|' null '';

----- TABLE REF_INSEE
-- ID Geofla;Code Commune;Code Canton;Code Arrondissement;Code Département;Code Région
drop table IF EXISTS ref_insee;
create table ref_insee(
	CODEINSEE varchar(10) primary key,
	CODEPOSTAL varchar(50),
	COMMUNE varchar(100),
	DEPARTEMENT varchar(40),
	REGION varchar(40),
	STATUT varchar(40),
	ALTITUDEMOYENNE float,
	SUPERFICIE float,
	POPULATION float,
	GEOPOINT2D varchar(40),
	GEOSHAPE json,
	IDGEOFLA varchar(10),
	CODECOMMUNE varchar(5),
	CODECANTON varchar(2),
	CODEARRONDISSEMENT varchar(1),
	CODEDEPARTEMENT varchar(3),
	CODEREGION varchar(3)
);

COPY ref_insee FROM '/Users/Drake/Desktop/DATA_Projet_R/REF_INSEE.CSV' CSV HEADER DELIMITER ';' null '';


