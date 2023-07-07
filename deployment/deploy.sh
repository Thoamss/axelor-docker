# This is the encryption salt
# IT MUST BE UNIQUE BY APPLICATION AND NEVER CHANGED DURING THE LIFETIME OF THE DATABASE
jwtSecret=34mBkf7B_Kj76gw1jY7n3Qd

# Load actual server config variables
. configFiles/deployConfig.cfg || ERROR_CONF_SPE=true
if [ "$ERROR_CONF_SPE" = true ]; then
  echo ""
  echo "--> Ce script ne doit pas être lancé manuellement !"
  exit 1
fi

# Only when updating application
if [ "$installed" = true ]; then
  # Try to find a Docker image by name (server config)
  echo ""
  echo "Vérification de l'absence de l'image de l'application sur le serveur ('$dockerImageName')"
  docker image inspect $dockerImageName || ERROR_ABS_IMG=true
  # If an error is thrown -> No image existe -> OK -> Else -> Image already exists -> ABORT
  if [ "$ERROR_ABS_IMG" != true ]; then
    echo ""
    echo "### Une image Docker '$dockerImageName' est déjà déployée sur le serveur ###"
    exit 1
  fi
fi

# Load new config variables
. "$gitRepo"/deployment/deployConfig.cfg # Override the previous deployConfig.cfg imported

# Try to find a Docker image by name (application config)
echo ""
echo "Vérification de la disponibilité du nom de l'image ('$dockerImageName')"
docker image inspect $dockerImageName || ERROR_DISP_IMG=true
# If an error is thrown -> No image exists -> OK -> Else -> Image already exists -> ABORT
if [ "$ERROR_DISP_IMG" != true ]; then
  echo ""
  echo "### Une image Docker '$dockerImageName' est déjà déployée sur le serveur ###"
  exit 1
fi

# Load actual server config variables
. configFiles/deployConfig.cfg # Override the previous deployConfig.cfg imported

# Specify the port used by the container (8080 for Spring Boot)
echo "" >>"$gitRepo"/deployment/deployConfig.cfg
echo "### For start.sh script ###" >>"$gitRepo"/deployment/deployConfig.cfg
echo "containerPort=8080" >>"$gitRepo"/deployment/deployConfig.cfg
echo ""
echo "SpringBoot container port is defined to 8080"

echo ""
echo ""
# Ask user confirmation for server port
read -p "Confirmer le port pour l'application: " -i "$serverPort" -e appPort
# Update the given port if it has changed
sed -i "s/^serverPort=.*$/serverPort=$appPort/" "$gitRepo"/deployment/deployConfig.cfg

# Load new config variables
. "$gitRepo"/deployment/deployConfig.cfg # Override the previous deployConfig.cfg imported

# Ask user confirmation for version number
read -r -p "Confirmer la version de l'application: " -i "$appVersion" -e version
# Update the given version if it has changed
sed -i "s/^appVersion=.*$/appVersion=$version/" "$gitRepo"/deployment/deployConfig.cfg
