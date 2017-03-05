#!/bin/sh
set -e

WORKDIR=$(pwd)

ENV_artemis_USER=${artemis_USER:-admin}
ENV_artemis_PASSWORD=${artemis_PASSWORD:-topsecret007}
ENV_artemis_ROLE=${artemis_ROLE:-amq}
ENV_artemis_CLUSTER_USER=${artemis_ROLE:-artemisCluster}
ENV_artemis_CLUSTER_PASSWORD=${artemis_ROLE:-topsecret007-cluster}

if [ ! "$(ls -A /var/lib/artemis/etc)" ]; then
	# Create broker instance
	cd /var/lib && \
	  /opt/A-MQ7/bin/artemis create artemis \
		--home /opt/A-MQ7 \
		--user $ENV_artemis_USER \
		--password $ENV_artemis_PASSWORD \
		--role $ENV_artemis_ROLE \
		--require-login \
		--cluster-user $ENV_artemis_CLUSTER_USER \
		--cluster-password $ENV_artemis_CLUSTER_PASSWORD

	# Get managment accesible from the outside
	sed -ie 's/localhost:8161/0.0.0.0:8161/g' artemis/etc/bootstrap.xml

  chown -R artemis:artemis /var/lib/artemis

	cd $WORKDIR
fi

# Log to tty to enable docker logs container-name
sed -ie "s/logger.handlers=.*/logger.handlers=CONSOLE/g" ../etc/logging.properties

# Update min memory if the argument is passed
if [[ "$ARTEMIS_MIN_MEMORY" ]]; then
  sed -ie "s/-Xms512M/-Xms$ARTEMIS_MIN_MEMORY/g" ../etc/artemis.profile
fi

# Update max memory if the argument is passed
if [[ "$ARTEMIS_MAX_MEMORY" ]]; then
  sed -ie "s/-Xmx1024M/-Xmx$ARTEMIS_MAX_MEMORY/g" ../etc/artemis.profile
fi

if [ "$1" = 'artemis-server' ]; then
	exec su-exec artemis "./artemis" "run"
fi

exec "$@"
