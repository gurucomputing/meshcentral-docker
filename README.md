# Meshcentral Docker
Repository for building meshcentral images in docker

## Meshcentral Summary
Meshcentral is a remote management and monitoring (RMM) system designed to run in a web browser. Meshcentral supports Linux, Windows, MacOS, and (to a certain extent) Android.

Meshcentral is developed by a separate team: their repository can be found at https://github.com/Ylianst/MeshCentral. This repository is unaffiliated and meant for a docker deployment of the platform.

## Meshcentral Documentation
For advanced configurations, you can modify the `config.json` that will be generated at `/meshcentral/meshcentral-data`. You can use the following resources for more information:

* [Basic config.json configuration](https://github.com/Ylianst/MeshCentral/blob/master/sample-config.json)
* [Advanced config.json configuration](https://github.com/Ylianst/MeshCentral/blob/master/sample-config-advanced.json)
* [Full schema documentation for config.json](https://github.com/Ylianst/MeshCentral/blob/master/meshcentral-config-schema.jsonp-0[])
* [Meshcentral User Guide](https://info.meshcentral.com/downloads/MeshCentral2/MeshCentral2UserGuide.pdf)
* [Meshcentral Installer Guide](https://info.meshcentral.com/downloads/MeshCentral2/MeshCentral2InstallGuide.pdf)

## Docker Container Features

* Nightly automated builds thanks to github actions
* Environment Variables for different starting configurations
* Non-Root container by default
* Volumes will automatically adjust file permissions to the docker user

## Container Defaults
* Ports are `80`/`443`
* Certificates are self signed and generated on first boot
    * Signed certificates can be provided by a reverse proxy (example given in documentation) or by editing 
* Database is an embedded database by default (NeDB)
    * Database can be changed to mongodb using environment variables or editing `config.json` in `meshcentral-data`. Recommended for production.
* Container will run as the `node` user, with a UID of `1000` and GID of `1000`
    * If you manually set the UID and GID, the container will automatically adjust file permissions on start

## Environment Variables
The docker image can take multiple environment variables as arguments. All environment variables are optional.

Environment variables will **only** apply on first run, when no `config.json` file is present. If the `config.json` file already exists, environment variables will have no effect.

| Variable  | Description | Example |
| ------------- | ------------- | ------------- |
| MONGODB_URL | url to mongo database | `mongodb://meshcentral-db:27017` |
| MONGODB_NAME | database name | `meshcentral` |
| DB_ENCRYPT_KEY | secret/key to encrypt the mongodb database | `${DB_ENCRYPT_KEY}` |
| AGENT_PORT  | optional port for agents to connect on | `8800` |

## Volumes
There are three volumes in question for persistent data:
| Volume | Description
| --- | --- |
| `/meshcentral/meshcentral-data` | Main configuration folder, holds `config.json`, all certs, and the embedded db (if in use) |
| `/meshcentral/meshcentral-files` | folder that holds files uploaded to the meshcentral server |
| `/meshcentral/meshcentral-backup` | automated database backs will reside in this folder |

## Examples
Example docker-compose files can be found in the repository. For your convenience, the three most common examples are here:

### Example: Simple Configuration
Most basic meshcentral configuration
```yaml
version: '2'
services:
  meshcentral:
    container_name: meshcentral
    image: ghcr.io/GuruComputing/meshcentral:latest
    restart: "always"
    volumes:
      - ./container-data/meshcentral-data:/meshcentral/meshcentral-data
      - ./container-data/meshcentral-files:/meshcentral/meshcentral-files
      - ./container-data/meshcentral-backup:/meshcentral/meshcentral-backup
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 80:80
      - 443:443
```

### Example: Reverse Proxy with Caddy

### Example: 