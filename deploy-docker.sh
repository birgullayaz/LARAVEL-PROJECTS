docker-compose down
docker rmi $(docker images -f "dangling=true" -q)
yes | docker container prune
docker pull saide044/saide-backoffice:latest
docker-compose up -d