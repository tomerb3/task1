#!/bin/bash

### stop docker-compose and webcontainer if needed ###
docker stop webcontainer
docker rm webcontainer
docker-compose down
sleep 4
#####################################

### start docker-compose ###
docker-compose up -d
############################

### make data.json from data.txt and wait 20 seconds for mongo to be ready ###
sed 's/^/{ "/' data.txt | sed 's/$/" }/' | sed 's/: /": "/g'  | sed 's/, /", "/g' > data.json
sleep 20
##############################################################################

### copy json inside container and run mongoimport ###
docker cp data.json mongo1:/tmp/data.json
docker exec mongo1 mongoimport -u "root" -p "example" --authenticationDatabase "admin" -d "cr-db" -c "users" --file /tmp/data.json
sleep 10
######################################################

### Export db from container to file export.csv in the host folder ###
docker exec mongo1 mongoexport -u "root" -p "example" --authenticationDatabase admin -d "cr-db" -c "users" --type=csv --fields _id,firstname,lastname,username,password > export.csv
######################################################################

### $5 is password - will not show the password in final file ###
awk -F "," '{ print $2, $3, $4  }' export.csv > export2.csv
#################################################################

###sort by firstname and Capital first letter ###
(head -n 1 export2.csv && tail -n +2 export2.csv | sort)  | sed -e "s/\b\(.\)/\u\1/g" |tr -s " " "," > export3.csv
#del temp files
\rm -f export.csv
\rm -f export2.csv
mv export3.csv export.csv
cat export.csv
#################################################

### nginx web server with index.html from export.csv ###
awk -f file.awk export.csv > index.html
docker build -t websrv1:v1 .
docker run -d --name webcontainer -p 8882:80 websrv1:v1
echo try chrome with url http://localhost:8882
########################################################
