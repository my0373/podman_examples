#!/usr/bin/bash
#set -x




## Some basic settings assuming you will be running it in a podman pod.
POD_NAME="charmr"
PGADMIN_DEFAULT_EMAIL="myork@redhat.com"
PGADMIN_DEFAULT_PASSWORD="redhat123"
PG_DEFAULT_PASSWORD="redhat123"
PG_DEFAULT_USER="myork"
PGADMIN_CONTAINER_NAME="pgadmin"
PG_CONTAINER_NAME="postgresql"
PGADMIN_CONTAINER_IMAGE="docker.io/dpage/pgadmin4"
PG_CONTAINER_IMAGE="registry.redhat.io/rhel8/postgresql-12:latest"
PGADMIN_EXT_PORT="9876"
PGADMIN_INT_PORT="80"
PG_HOST_VOL_PATH="/home/myork/tmp/postgres"
POSTGRES_ADMIN_PASSWORD="redhat123"
PG_DB_NAME="db"


## Authenticate with the Red Hat registry. 
## Not essential, but I want to use the supported Red Hat images.
podman login registry.redhat.io

## WARNING DESTRUCTIVE LAZY THINGS HERE
## Delete the existing pod
podman pod stop ${POD_NAME}
podman pod rm ${POD_NAME}

## Create the pod 
podman pod create --name ${POD_NAME} -p ${PGADMIN_EXT_PORT}:${PGADMIN_INT_PORT}

## Here we actually run the container image. As we are going to run this within a pod, we don't specify any ports here. We do that at the pod level,
## If you want to run this without a pod, then obviously, you'll need to add those in yourself.
podman run --pod=${POD_NAME} \
-e 'PGADMIN_DEFAULT_EMAIL='${PGADMIN_DEFAULT_EMAIL} \
-e 'PGADMIN_DEFAULT_PASSWORD='${PGADMIN_DEFAULT_PASSWORD} \
--name ${PGADMIN_CONTAINER_NAME}   \
-d ${PGADMIN_CONTAINER_IMAGE}


## Postgres container
podman run --pod=${POD_NAME} \
-v ${PG_HOST_VOL_PATH}:/var/lib/postgresql/data:Z \
-e 'POSTGRESQL_PASSWORD'=${PG_DEFAULT_PASSWORD} \
-e 'POSTGRESQL_USER'=${PG_DEFAULT_USER} \
-e 'POSTGRESQL_ADMIN_PASSWORD'=${PG_ADMIN_PASSWORD} \
-e 'POSTGRESQL_DATABASE'=${PG_DB_NAME} \
--name ${PG_CONTAINER_NAME} \
-d ${PG_CONTAINER_IMAGE}


## Once the pod is up and running display a simple stats check on the pod.
echo "To check the status of the pods run"
echo "podman pod stats ${POD_NAME}"
echo ""
echo "To login to pgadmin, open your web browser to http://127.0.0.1:${PGADMIN_EXT_PORT}/"
echo "PGAdmin credentials: ${PGADMIN_DEFAULT_EMAIL}/${PGADMIN_DEFAULT_PASSWORD}"
echo "Postgres server admin credentials: postgres/${POSTGRES_ADMIN_PASSWORD}"
echo "Postgres server user credentials: ${PG_DEFAULT_USER}/${PG_DEFAULT_PASSWORD}"


podman ps -p
