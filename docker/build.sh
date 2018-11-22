#!/bin/sh

set -e

echo "\033[32m------------------ 1/ Cloning OFF -----------------------\033[0m";
git clone git@github.com:openfoodfacts/openfoodfacts-server.git

echo "\033[32m------------------ 2/ Creating directories --------------\033[0m";
cd openfoodfacts-server
mkdir logs
mkdir products
mkdir -p html/images/products

echo "\033[32m------------------ 3/ File configuration ----------------\033[0m";
cp lib/ProductOpener/Config2_sample.pm lib/ProductOpener/Config2_sample_docker.pm
sed -i -e 's|$server_domain = "openfoodfacts.org";|$server_domain = "off.localhost";|g' lib/ProductOpener/Config2_sample_docker.pm
sed -i -e 's|"/home/off/html"|"/var/www/html/html"|g' lib/ProductOpener/Config2_sample_docker.pm
sed -i -e 's|"/home/off"|"/var/www/html"|g' lib/ProductOpener/Config2_sample_docker.pm
sed -i -e 's|"mongodb://localhost"|"mongodb://mongo"|g' lib/ProductOpener/Config2_sample_docker.pm
# sed -i -e 's|$server_domain = "openfoodfacts.org";|$server_domain = $ENV{"OFF_SERVER_DOMAIN"};|g' lib/ProductOpener/Config2_sample_docker.pm
# sed -i -e 's|"/home/off/html"|$ENV{"OFF_WWW_ROOT"}|g' lib/ProductOpener/Config2_sample_docker.pm
# sed -i -e 's|"/home/off"|$ENV{"OFF_DATA_ROOT"}|g' lib/ProductOpener/Config2_sample_docker.pm
# sed -i -e 's|"off"|$ENV{"OFF_MONGODB"}|g' lib/ProductOpener/Config2_sample_docker.pm
# sed -i -e 's|"mongodb://localhost"|$ENV{"OFF_MONGODB_HOST"}|g' lib/ProductOpener/Config2_sample_docker.pm
sed -i -e 's|*|no|g' lib/ProductOpener/Config2_sample_docker.pm

echo "\033[32m------------------ 4/ Retrieve products -----------------\033[0m";
wget http://static.openfoodfacts.org/exports/39-.tar.gz
tar -xzvf 39-.tar.gz -C products
rm 39-.tar.gz

echo "\033[32m------------------ 5/ Retrieve images -------------------\033[0m";
wget http://static.openfoodfacts.org/exports/39-.images.tar.gz
tar -xzvf 39-.images.tar.gz -C html/images/products
rm 39-.images.tar.gz

echo "\033[32m------------------ 6/ Yarn configuration-----------------\033[0m";
yarn install
yarn run build

echo "\033[32m------------------ 7/ Docker compose --------------------\033[0m";
cd -
docker-compose build