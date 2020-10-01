CONTAINER_NAME=song
TAG=jvm
mvn clean package -DskipTests=true
echo "*" > .dockerignore
echo "!target/*-runner" >>.dockerignore
echo "!target/*-runner.jar" >> .dockerignore
echo "!target/lib/*" >> .dockerignore
docker build -f src/main/docker/Dockerfile.jvm \
-t ${CONTAINER_NAME}:${TAG} .
