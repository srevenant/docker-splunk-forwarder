The docker plugin for splunk is nice, but not functional.

This is because the logs come in as the raw JSON msg from docker (with stdout/stderr split).

I would like better intelligence around this.  The suggestion in the meantime is to switch to raw input on the docker plugin, but that is not working properly (on the current release).

In the meantime, this is a container that just imports the raw container files, parses them out to /log and runs the standard splunk agent to import them.

The logs come in with a usable name, and splunk can parse them as normal.

This works in docker swarm.

You will want to update your docker-splunk-forwarder/agent/serverufapp/default files.  These are bogus values.

For persistence between container restarts, create the volume /data/splunk/etc

Add to swarm with:

    docker stack deploy -c splunk-forwarder.yml splunk

