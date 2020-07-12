# Cockpit Sync

Handles saving and restoring of internal data stores of Cockpit CMS (getcockpit.com), an open source content management system, developed and maintained by Agentejo.

Assumes that Cockpit runs in a Docker container with its own dedicated volume mounted at `/var/www/html/storage` inside the container environment. If the targeted Cockpit instance runs openly outside of containerization, no special tools are required to save and restore its data.

See `cockpit-sync --help` for more information.