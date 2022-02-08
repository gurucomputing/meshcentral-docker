# Meshcentral Docker
Repository for building meshcentral images in docker
```
docker run -p 80:80 -p 443:443 ghcr.io/gurucomputing/meshcentral-docker
```

![readme-gif](assets/readme-gif.gif)

## Meshcentral Summary
Meshcentral is a remote management and monitoring (RMM) system designed to run in a web browser. Meshcentral supports Linux, Windows, MacOS, and (to a certain extent) Android.

Meshcentral is developed by a separate team: their repository can be found at https://github.com/Ylianst/MeshCentral. This repository is unaffiliated and meant for a docker deployment of the platform.

## Meshcentral Documentation
For advanced configurations, you can modify the `config.json` that will be generated at `/meshcentral/meshcentral-data`. You can use the following resources for more information:

* [Basic config.json configuration](https://github.com/Ylianst/MeshCentral/blob/master/sample-config.json)
* [Advanced config.json configuration](https://github.com/Ylianst/MeshCentral/blob/master/sample-config-advanced.json)
* [Full schema documentation for config.json](https://github.com/Ylianst/MeshCentral/blob/master/meshcentral-config-schema.json)
* [Meshcentral User Guide](https://info.meshcentral.com/downloads/MeshCentral2/MeshCentral2UserGuide.pdf)
* [Meshcentral Installer Guide](https://info.meshcentral.com/downloads/MeshCentral2/MeshCentral2InstallGuide.pdf)

## Docker Container Features

* Nightly automated builds thanks to github actions
* Environment Variables for different starting configurations
* Non-Root container by default
* Volumes will automatically adjust file permissions to the docker user

## Docker Container Changelog
These mark changes to how the docker container operates. The version description defines where the change in question took place. Versions before the change will not be affected.
| Version | Change
| --- | ----
| 0.9.52 | initialization script will now perform additional checks regarding file permissions before resorting to overwriting file ownership |

## Docker Tags

If you want to stay on the bleeding edge, the `latest` tag will follow all version updates from the upstream Meshcentral (checked daily). Meshcentral is highly maintained and sees nearly daily updates.

If you are looking for a production or stable experience, the `stable` tag will follow any versions marked *stable* within the node repository for Meshcentral.

## Container Defaults
* Ports are `80`/`443`
* Certificates are self signed and generated on first boot
    * Signed certificates can be provided by a reverse proxy (example given in documentation) or by editing `config.json`
* Database is an embedded database by default (NeDB)
    * Database can be changed to mongodb using environment variables or editing `config.json` in `meshcentral-data`. Recommended for production.
* Container will run as the `node` user, with a UID of `1000` and GID of `1000`

## Environment Variables
The docker image can take multiple environment variables as arguments. All environment variables are optional.

Environment variables will **only** apply on first run, when no `config.json` file is present. If the `config.json` file already exists, environment variables will have no effect.

| Variable  | Description | Example |
| ------------- | ------------- | ------------- |
| MONGODB_URL | url to mongo database | `mongodb://meshcentral-db:27017` |
| MONGODB_NAME | database name | `meshcentral` |
| DB_ENCRYPT_KEY | secret/key to encrypt the mongodb database | `${DB_ENCRYPT_KEY}` |
| AGENT_PORT  | optional port for agents to connect on | `8800` |
| CERT | dns name for your server, needed for trusted TLS connections | `mesh.mydomain.com` |

## Volumes
There are three volumes in question for persistent data:
| Volume | Description
| --- | --- |
| `/meshcentral/meshcentral-data` | Main configuration folder, holds `config.json`, all certs, and the embedded db (if in use) |
| `/meshcentral/meshcentral-files` | folder that holds files uploaded to the meshcentral server |
| `/meshcentral/meshcentral-backup` | automated database backs will reside in this folder |

## Examples
Example docker-compose files can be found in the repository. For your convenience, the three most common examples are here:

### Example 1: Simple Configuration
Most basic meshcentral configuration
```yaml
version: '2'
services:
  meshcentral:
    container_name: meshcentral
    image: ghcr.io/gurucomputing/meshcentral-docker:latest
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

### Example 2: using MongoDB for Backend
initialize a meshcentral container with mongodb
```yaml
version: '2'
# This is example 2 from the documentation
services:
  meshcentral:
    container_name: meshcentral
    image: ghcr.io/gurucomputing/meshcentral-docker:latest
    restart: "always"
    volumes:
      - ./container-data/meshcentral-data:/meshcentral/meshcentral-data
      - ./container-data/meshcentral-files:/meshcentral/meshcentral-files
      - ./container-data/meshcentral-backup:/meshcentral/meshcentral-backup
      - /etc/localtime:/etc/localtime:ro
    environment:
      - MONGODB_URL=mongodb://meshcentral-db:27017
      - MONGODB_NAME=meshcentral
      - DB_ENCRYPT_KEY=${DB_ENCRYPT_KEY}
    ports:
      - 80:80
      - 443:443
    networks:
      - meshcentral-nw
  meshcentral-db:
    container_name: meshcentral-db
    image: mongo:latest
    restart: "always"
    volumes:
      - ./container-data/db:/data/db
      - /etc/localtime:/etc/localtime:ro
    # ports:
    #   - 27017:27017
    networks:
      - meshcentral-nw

networks:
  meshcentral-nw:
```

Also create a `.env` file for your secrets:

```
DB_ENCRYPT_KEY=mysecretpassword
```

### Example 3: Advanced Config with MongoDB, Agent Port, and Caddy Reverse Proxy
A full solution including an separate port for agent connections and caddy for reverse proxying and let's encrypt. This assumes port 80, 443, and 8800 are all forwarded from the docker host to the web (otherwise let's encrypt will fail)

```yaml
version: '2'
# This is example 3 from the documentation
services:
  meshcentral:
    container_name: meshcentral
    image: ghcr.io/gurucomputing/meshcentral-docker:latest
    restart: "always"
    volumes:
      - ./container-data/meshcentral-data:/meshcentral/meshcentral-data
      - ./container-data/meshcentral-files:/meshcentral/meshcentral-files
      - ./container-data/meshcentral-backup:/meshcentral/meshcentral-backup
      - /etc/localtime:/etc/localtime:ro
    environment:
      - MONGODB_URL=mongodb://meshcentral-db:27017
      - MONGODB_NAME=meshcentral
      - DB_ENCRYPT_KEY=${DB_ENCRYPT_KEY}
      - AGENT_PORT=8800
      - CERT=mesh.mydomain.com
    ports:
      - 8800:8800
      # - 80:80
      # - 443:443
    networks:
      - meshcentral-nw
      - reverseproxy-nw
  meshcentral-db:
    container_name: meshcentral-db
    image: mongo:latest
    restart: "always"
    volumes:
      - ./container-data/db:/data/db
      - /etc/localtime:/etc/localtime:ro
    # ports:
    #   - 27017:27017
    networks:
      - meshcentral-nw
  meshcentral-proxy:
    container_name: meshcentral-proxy
    image: caddy:latest
    restart: "always"
    volumes:
      - ./caddy/Caddyfile:/usr/share/caddy/Caddyfile
    ports:
      - 80:80
      - 443:443
    networks:
      - reverseproxy-nw

networks:
  meshcentral-nw:
  reverseproxy-nw:
```

Include your `.env` file of course:

```
DB_ENCRYPT_KEY=mysecretpassword
```

And include your `Caddyfile` under `caddy/Caddyfile`

```
reverse_proxy https://mesh.mydomain.com {
	reverse_proxy https://meshcentral:443 {
        transport http {
            tls_insecure_skip_verify
        }
    }
}
```

## Additional Notes

### SE-Linux Based Environments
If you are using an SE-Linux based environment (such as Fedora, CentOS, or equivalent), docker will deny file permissions in bind mounts. You must relabel or explicitly tell docker to ignore file labelling. You can ignore file labelling by adding the following to your service:

```yaml
services:
  meshcentral:
    security_opt:
      - label:disable
```
