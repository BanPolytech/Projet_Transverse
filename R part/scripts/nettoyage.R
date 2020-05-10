###########################################################################
#
# Formation MBA ESG - Big Data Chief Data Officer
#
# Projet Transverse
#
# Formateur : Sammartino
# Mail : 
#
#  Etudiants :  Meriam HAMMOUDA, 
#               Khaoula ELMOUTAMID
#               Lina SAIDANE
#               Esteban GOBERT
#
#  Mails : hammouda.meriam@yahoo.fr
#         khaoula.elmoutamid@gmail.com
#         lina.saidane96@gmail.com
#         esteban.gobert@me.com
#
###########################################################################

# Charger les packages:---------------------------------------------
library(dplyr)
library(summarytools)
library(ggplot2)
library(zoo)

## Definition du perimetre
# On veut client non vip et churner
CLIENT_nVIP_CHURNER <- CLIENT %>%
  filter(VIP == 0,
         DATEFINADHESION < as.Date("2018-01-01"))

## Nettoyage des données:----------------------------------

### Table client
# On observe les variables
dfSummary(CLIENT_nVIP_CHURNER[-1], round.digits = 2)

#### CIVILITE
# On voit que la meme valeur possede plusieurs modalités, on va les regrouper
CLIENT_nVIP_CHURNER <- CLIENT_nVIP_CHURNER %>%
  mutate(CIVILITE = recode(`CIVILITE`,
                           "Mme" = "MADAME",
                           "madame" = "MADAME",
                           "monsieur" = "MONSIEUR",
                           "Mr" = "MONSIEUR"))

# Pas de valeurs manquantes

#### DATENAISSANCE
##### Valeurs manquantes
# Il y a 40.56% de valeurs manquantes
# --> méthode d'imputation choisie : LOCF
# afin de ne pas briser la distribution
CLIENT_nVIP_CHURNER$DATENAISSANCE_R <- na.locf(CLIENT_nVIP_CHURNER$DATENAISSANCE)

##### valeurs extremes
# On voit que la valeur minimum est 1779-03-13 et la maximum 8951-04-01
# Pour traiter ces valeurs extremes nous allons déduire les ages et filtrer seulement les clients ayant entre 18 et 90 ans
CLIENT_nVIP_CHURNER$AGE <- 2018 - as.numeric(format(CLIENT_nVIP_CHURNER$DATENAISSANCE_R, "%Y"))
CLIENT_nVIP_CHURNER <- CLIENT_nVIP_CHURNER %>%
  filter(AGE >= 18,
         AGE <= 90)

#### MAGASIN
# Il y a plusieurs modalités possible, pour vérifier qu'elles sont toutes possibles
# on les compare aux modalités de la colonne CODESOCIETE du dataset REF_MAGASIN
levels(as.factor(CLIENT_nVIP_CHURNER$MAGASIN)) == levels(as.factor(REF_MAGASIN$CODESOCIETE))

# Toutes présentes donc pas de valeur aberrante

#### DATEDEBUTADHESION, DATEREADHESION et DATEFINADHESION
# Ces 3 dates sont liées, les valeurs manquantes présentes dans la colonne DATEREADHESION signifie que le client n'a pas
# encore effectué de réadhesion. On n'effectue pas d'imputation car ces NAs signifient autre chose.

#### VIP
# Colonne sur laquelle on a opéré le filtrage initial par rapport au périmètre

#### CODEINSEE
# On peut en déduire les valeurs manquantes par la géolocalisation des magasin via le dataset REF_INSEE du site opendatasoft
# On rend iso LIBELLEREGIONCOMMERCIALE et Region
REF_MAGASIN$LIBELLEREGIONCOMMERCIALE_UPPER <- iconv(toupper(REF_MAGASIN$LIBELLEREGIONCOMMERCIALE), to = "ASCII//TRANSLIT")
REF_MAGASIN$LIBELLEREGIONCOMMERCIALE_UPPER <- gsub("['`^~\"]", "", REF_MAGASIN$LIBELLEREGIONCOMMERCIALE_UPPER)

newINSEEcol <- CLIENT_nVIP_CHURNER %>%
  left_join(., REF_MAGASIN, by = c('MAGASIN' = 'CODESOCIETE')) %>%
  left_join(., REF_INSEE, by = c('VILLE' = 'Commune', 'LIBELLEDEPARTEMENT' = 'Code Département', 'LIBELLEREGIONCOMMERCIALE_UPPER' = 'Région')) %>%
  mutate(CODEINSEE = coalesce(CODEINSEE, `Code INSEE`)) %>%
  select(CODEINSEE)

CLIENT_nVIP_CHURNER$CODEINSEE <- newINSEEcol$CODEINSEE
  
#### PAYS
levels(as.factor(CLIENT_nVIP_CHURNER$PAYS))
# Pas de valeur aberrante
# Il y a une valeur manquante que l'on peut déduire grâce au code INSEE


### Filtrate des autres dataset
ENTETES_TICKET_filtred <- ENTETES_TICKET_V4 %>%
  filter(IDCLIENT %in% CLIENT_nVIP_CHURNER$IDCLIENT)

LIGNES_TICKET_filtred <- LIGNES_TICKET_V4 %>%
  filter(IDTICKET %in% ENTETES_TICKET_filtred$IDTICKET)

### Table entetes
ENTETES_TICKET_filtred %>%
  select(-c(IDTICKET, IDCLIENT)) %>%
  dfSummary(round.digits = 2)

levels(as.factor(ENTETES_TICKET_filtred$MAG_CODE)) %in% levels(as.factor(REF_MAGASIN$CODESOCIETE))
# Il ne semble pas y avoir de probleme sur les variables TIC_DATE, MAG_CODE

#### TIC_TOTALTTC
ggplot(ENTETES_TICKET_filtred, aes(x = TIC_TOTALTTC)) +
  geom_boxplot(alpha = 0.8)

ggplot(ENTETES_TICKET_filtred, aes(x = TIC_TOTALTTC)) +
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)

### Table lignes
LIGNES_TICKET_filtred %>%
  select(-c(IDTICKET)) %>%
  dfSummary(round.digits = 2)
