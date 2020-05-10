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

# On fixe le wd pour le sourcage
wd <- getwd()
if(grepl("/scripts", wd, fixed = TRUE)) {
  setwd("..")
}

# Charger les packages:---------------------------------------------
library(readr)

# Step n°1: Initialisation d'un projet R -------------------------

## 1- La création d'un projet R avec les répertoires: inputs, outputs, scripts, r_data, functions
# --> script "makeFolders.R" à la racine du dossier de travail

## 2- Importation des données:----------------------------------
CLIENT <- read_delim("~/Desktop/DATA_Projet_R/CLIENT.CSV", 
                     "|", escape_double = FALSE, col_types = cols(DATENAISSANCE = col_date(format = "%d/%m/%Y %H:%M:%S"),
                                                                  DATEDEBUTADHESION = col_date(format = "%d/%m/%Y %H:%M:%S"), 
                                                                  DATEFINADHESION = col_date(format = "%d/%m/%Y %H:%M:%S"), 
                                                                  DATEREADHESION = col_date(format = "%d/%m/%Y %H:%M:%S")), 
                     trim_ws = TRUE)

ENTETES_TICKET_V4 <- read_delim("~/Desktop/DATA_Projet_R/ENTETES_TICKET_V4.CSV", 
                                "|", escape_double = FALSE, col_types = cols(TIC_DATE = col_date(format = "%Y-%m-%d %H:%M:%S")), 
                                trim_ws = TRUE)

LIGNES_TICKET_V4 <- read_delim("~/Desktop/DATA_Projet_R/LIGNES_TICKET_V4.CSV", 
                               "|", escape_double = FALSE, trim_ws = TRUE)
LIGNES_TICKET_V4[,4:7] <- sapply(LIGNES_TICKET_V4[,4:7], gsub, pattern = ',', replacement = '.')
LIGNES_TICKET_V4[,4:7] <- sapply(LIGNES_TICKET_V4[,4:7], as.numeric)

REF_ARTICLE <- read_delim("~/Desktop/DATA_Projet_R/REF_ARTICLE.CSV", 
                          "|", escape_double = FALSE, trim_ws = TRUE)

REF_MAGASIN <- read_delim("~/Desktop/DATA_Projet_R/REF_MAGASIN.CSV", 
                          "|", escape_double = FALSE, trim_ws = TRUE)

REF_INSEE <- read_delim("~/Desktop/DATA_Projet_R/REF_INSEE.csv", 
                        ";", escape_double = FALSE, trim_ws = TRUE)
