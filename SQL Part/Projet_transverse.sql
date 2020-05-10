-- Projet Transverse - MBDCDO - SQL
-- 
-- 
-- Exercice 1. Étude global
-- a. Répartition Adhérent / VIP
-- Note : le critère le plus au-dessus est prioritaire, exemple : un client étant VIP, et ayant adhéré sur l'année N-1 sera compté comme étant VIP

-- extraire csv pour data viz
select * from
-- VIP : client étant VIP (VIP = 1)
	(select count(idclient) as VIP from client
	where vip = 1) as VIP,

-- NEW_N2 : client ayant adhéré au cours de l'année N-2 (date début adhésion)
	(select count(idclient) as NEW_N2 from client
	where vip = 0 and extract('year' from datedebutadhesion) = '2016') as NEW_N2,

-- NEW_N1 : client ayant adhéré au cours de l'année N-1 (date début adhésion)
	(select count(idclient) as NEW_N1 from client
	where vip = 0 and extract('year' from datedebutadhesion) = '2017') as NEW_N1,

-- ADHÉRENT : client toujours en cours d'adhésion (date de fin d'adhésion > 2018/01/01)
	(select count(idclient) as ADHERENT from client
	where vip = 0 and datedebutadhesion < '2016/01/01' and datefinadhesion > '2018/01/01') as ADHERENT,

-- CHURNER : client ayant churner (date de fin d'adhésion < 2018/01/01)
	(select count(idclient) as CHURNER from client
	where vip = 0 and datedebutadhesion < '2016/01/01' and datefinadhesion < '2018/01/01') as CHURNER;


-- b. Comportement du CA GLOBAL par client N-2 vs N-1
-- Constituer une boîte à moustache pour chaque année (N-2 et N-1) comparant le CA TOTAL (TTC) des clients (sommer les achats par client par années)
-- on enlevera les valeurs extremes grace à la fonction ntile en ne prenant que les ntile > 1 et < 99

-- extraire csv pour data viz
select sum(tic_totalttc), idclient, extract('year' from tic_date) as year, ntile(100) over (order by sum(tic_totalttc)) from entetes_ticket
group by idclient, year;

-- c. Répartition par âge x sexe
-- Constituer un graphique montrant la répartition par âge x sexe sur l'ensemble des clients.
alter table client
	add age_tranche varchar(5);

update client
	set age_tranche =
		(case 
		when age < 18 then '<18'
		when age >= 18 and age < 28 then '18-27'
 		when age >= 28 and age < 38 then '28-37'
 		when age >= 38 and age < 48 then '38-47'
 		when age >= 48 and age < 58 then '48-57'
 		when age >= 58 and age < 68 then '58-67'
 		when age >= 68 and age < 78 then '68-77'
 		when age >= 78 and age < 88 then '78-87'
 		when age >= 88 and age < 98 then '88-97'
  		when age >= 98 then '>97'
		else null
	end);

-- extraire csv pour data viz
select civilite, age, age_tranche from client
where age IS NOT null and age < 98 and age > 17;


-- Exercice 2. Étude par magasin
-- a. Résultat par magasin (+1 ligne Total)
drop table etude_magasin;
create table etude_magasin (
	magasin varchar(3) primary key,
	nb_clients int,
	actifs_Nmoins2 int,
	actifs_Nmoins1 int,
	prct_Nmoins2VSNmoins1 float,
	totalTTCNmoins2 int,
	totalTTCNmoins1 int,
	diffTotaux int,
	indEvol int
);

-- MAGASIN
-- NOMBRE DE CLIENT RATTACHE AU MAGASIN (avec une color_bar en fonction de la quantité)
insert into etude_magasin(magasin, nb_clients)
select magasin, count(idclient) from client
where magasin != 'EST'
group by magasin;

-- Nombre de client actif sur N-2
update etude_magasin
	set actifs_nmoins2 = subquery.aggregat
	from (select mag_code, count(distinct idclient) as aggregat
		  from entetes_ticket
		  where extract('year' from tic_date) = '2016'
		  group by mag_code) as subquery
	where etude_magasin.magasin = subquery.mag_code;

-- Nombre de client actif sur N-1
update etude_magasin
	set actifs_nmoins1 = subquery.aggregat
	from (select mag_code, count(distinct idclient) as aggregat
		  from entetes_ticket
		  where extract('year' from tic_date) = '2017'
		  group by mag_code) as subquery
	where etude_magasin.magasin = subquery.mag_code;

-- % CLIENT N-2 vs N-1 (couleur police : vert si positif, rouge si négatif)
-- on enleve 100 au calcul pour que le resultat soit de la forme +/-n%
update etude_magasin
	set prct_Nmoins2VSNmoins1 = round((actifs_nmoins1 / actifs_nmoins2::numeric) * 100 - 100, 2);

-- TOTAL_TTC N-2
update etude_magasin
	set totalttcnmoins2 = subquery.aggregat
	from (select mag_code, sum(tic_totalttc) as aggregat
		  from entetes_ticket
		  where extract('year' from tic_date) = '2016'
		  group by mag_code) as subquery
	where etude_magasin.magasin = subquery.mag_code;
	
-- TOTAL_TTC N-1
update etude_magasin
	set totalttcnmoins1 = subquery.aggregat
	from (select mag_code, sum(tic_totalttc) as aggregat
		  from entetes_ticket
		  where extract('year' from tic_date) = '2017'
		  group by mag_code) as subquery
	where etude_magasin.magasin = subquery.mag_code;

-- Différence entre N-2 et N-1 (couleur police : vert si positif, rouge si négatif)
update etude_magasin
	set diffTotaux = totalttcnmoins2 - totalttcnmoins1;

-- Indice évolution (icône de satisfaction : positif si %client actif évolue et total TTC aussi, négatif si
-- diminution des 2 indicateurs, moyen seulement l'un des deux diminue)
update etude_magasin
	set indevol = 
	(case 
		when prct_nmoins2vsnmoins1 < 0 and difftotaux < 0 then -1
	 	when prct_nmoins2vsnmoins1 < 0 and difftotaux > 0 then 0
		when prct_nmoins2vsnmoins1 > 0 and difftotaux < 0 then 0
	 	when prct_nmoins2vsnmoins1 > 0 and difftotaux > 0 then 1
		else null
	end);

-- extraire csv pour data viz
select * from etude_magasin
order by indevol desc;

-- b. Distance CLIENT / MAGASIN
alter table client
	add latitude float,
	add longitude float,
	add distance varchar(20);
	
alter table ref_magasin
	add latitude float,
	add longitude float;

update client
	set latitude = subquery.lat,
		longitude = subquery.long
	from (select codeinsee, split_part(ri.geopoint2d, ',', 1)::float as lat, split_part(ri.geopoint2d, ',', 2)::float as long
		 from ref_insee ri) as subquery
	where client.codeinsee = subquery.codeinsee;

update ref_magasin
	set latitude = subquery.lat,
		longitude = subquery.long
	from (select commune, split_part(ri.geopoint2d, ',', 1)::float as lat, split_part(ri.geopoint2d, ',', 2)::float as long
		 from ref_insee ri) as subquery
	where replace(replace(replace(ref_magasin.ville, ' CEDEX', ''), ' ', '-'), 'ST', 'SAINT') = replace(subquery.commune, ' ', '-');
	
---- On ajoute manuellement les informations geolocales de LES MILLES
update ref_magasin
	set latitude = 43.5000000000,
		longitude = 5.3833300000
	where ville = 'LES MILLES';

---- fonction pour calculer la distance entre 2 points
CREATE OR REPLACE FUNCTION calculate_distance(lat1 float, lon1 float, lat2 float, lon2 float, units varchar)
RETURNS float AS $dist$
    DECLARE
        dist float = 0;
        radlat1 float;
        radlat2 float;
        theta float;
        radtheta float;
    BEGIN
        IF lat1 = lat2 OR lon1 = lon2
            THEN RETURN dist;
        ELSE
            radlat1 = pi() * lat1 / 180;
            radlat2 = pi() * lat2 / 180;
            theta = lon1 - lon2;
            radtheta = pi() * theta / 180;
            dist = sin(radlat1) * sin(radlat2) + cos(radlat1) * cos(radlat2) * cos(radtheta);

            IF dist > 1 THEN dist = 1; END IF;

            dist = acos(dist);
            dist = dist * 180 / pi();
            dist = dist * 60 * 1.1515;

            IF units = 'K' THEN dist = dist * 1.609344; END IF;
            IF units = 'N' THEN dist = dist * 0.8684; END IF;

            RETURN dist;
        END IF;
    END;
$dist$ LANGUAGE plpgsql;

update client
	set distance = (case
		when calculate_distance(sq.lat1, sq.long1, sq.lat2, sq.long2, 'K') <= 5 then '1. 0 à 5km'
		when calculate_distance(sq.lat1, sq.long1, sq.lat2, sq.long2, 'K') <= 10 then '2. 5 à 10km'
		when calculate_distance(sq.lat1, sq.long1, sq.lat2, sq.long2, 'K') <= 20 then '3. 10 à 20km'
		when calculate_distance(sq.lat1, sq.long1, sq.lat2, sq.long2, 'K') <= 50 then '4. 20 à 50km'
		when calculate_distance(sq.lat1, sq.long1, sq.lat2, sq.long2, 'K') > 50 then '5. plus de 50km'
		else null
	end)
	from (select c.idclient as idclient, c.latitude as lat1, c.longitude as long1, rm.latitude as lat2, rm.longitude as long2 from client c
		 join ref_magasin rm on(c.magasin = rm.codesociete)
		 where c.latitude is not null and c.longitude is not null) as sq
	where client.idclient = sq.idclient;

-- extraire csv pour data viz
-- les valeurs null sont des clients qui n'ont pas de code insee ou alors qui en ont un mais qui n'est pas répertorié dans le dataset de référence
-- on choisit de ne pas les considérer
select count(*), distance from client
where distance is not null
group by distance;


-- Exercice 3. Étude par univers

-- a. ETUDE PAR UNIVERS

-- extraire csv pour data viz
-- cast de la colonne sum(total) en float car money non exploitable
select extract('year' from et.tic_date) as year, ra.codeunivers, sum(total)::numeric::float8 from lignes_ticket li
join ref_article ra on (li.idarticle = ra.codearticle)
join entetes_ticket et on (li.idticket = et.idticket)
group by ra.codeunivers, year;

-- b. TOP PAR UNIVERS
-- groupage basique sans top 5
select ra.codeunivers, ra.codefamille, sum(margesortie)::numeric::float8 as sum FROM lignes_ticket li
join ref_article ra on (li.idarticle = ra.codearticle)
group by codeunivers, codefamille
order by sum desc;

-- extraire csv pour data viz
-- en filtrant avec un ranking sur la marge
select rank_filter.* from (
	select ra.codeunivers, ra.codefamille, sum(margesortie)::numeric::float8, rank() over (
		partition by ra.codeunivers
		order by sum(margesortie) desc
	)
	from lignes_ticket li
	join ref_article ra on (li.idarticle = ra.codearticle)
	group by codeunivers, codefamille
) rank_filter
where rank <= 5
order by codeunivers, rank_filter.sum;

