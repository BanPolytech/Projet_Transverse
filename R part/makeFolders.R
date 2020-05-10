########## Script de génération des dossiers du dossier de travail

### Fonction createFolders
## params : 
#   dirnames : vecteur de strings (les noms des dossiers à créer)
createFolders <- function(dirnames) {
  for(dirname in dirnames) {
    if(!dir.exists(dirname)) {
      dir.create(dirname)
    }
  }
}

dirnames <- c("inputs", "outputs", "scripts", "R_data", "function")

createFolders(dirnames)
