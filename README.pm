The docker log plugin for splunk is nice, but not currently functional.  This is because the logs come in as the raw JSON msg from docker (with stdout/stderr split).  The suggestion in the meantime is to switch to raw input on the docker plugin, but that is not working properly (on the current release).

In the meantime, this is a container that just imports the raw container files, parses them out to /log and runs the standard splunk agent to import them.

The logs come in with a usable name, and splunk can parse them as normal.

This works in docker swarm.

The `docker-splunk-forwarder` agent watches the docker log stream files and splits them back to their raw format into `/log`.  Persistence between container restarts is maintained by using external volumes for `/log/` and `$SPLUNK_HOME/var`.

# setup

You will want to update the environment variables to suite your setup.  The splunk files located in `config` are put into the container and altered at startup by `splunk-docker` before launching splunk, and then launching the docker-splunk-forwarder agent.

Environment Vars:

* ROTATE_FILE_BYTES &mdash; how many bytes in a file before the agent rotates it out (default=10mb).  Only one rotation is used, as splunk should be shipping the content.
* IGNORE_CONTAINERS_RX &mdash; a regex to exclude container logs if you so desire.  Look in `/log/` after launching to determine if it is working properly.
* AGENT_CONFIG &mdash; defaults are given in Dockerfile, and these are probably okay.
* SPLUNK_GROUP &mdash; the group to use in outputs.conf
* SPLUNK_APP_INDEX &mdash; which index you want your container logs directed into
* SPLUNK_HOST_INDEX &mdash; which index you want your host logs directed into

Feel free to update `config/*` files to match your environment.

docker-compose.yml will work for `docker-compose` as well as `docker stack deploy` in swarm mode:

    docker stack deploy -c splunk-forwarder.yml splunk


