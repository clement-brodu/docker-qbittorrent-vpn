# docker-qbittorrent-vpn

Lightweight Docker container with qbittorrent and vpn

Based on the [LinuxServer.io qBittorrent](https://github.com/linuxserver/docker-qbittorrent/) image.

This image allow to start an [OpenVPN](https://openvpn.net/) client before starting [qBittorrent](https://www.qbittorrent.org/).

## Version Tags

This image provides various versions that are available via tags. Please read the descriptions carefully and exercise caution when using unstable or development tags.

| Tag | Available | Description |
| :----: | :----: |--- |
| latest | ✅ | Stable qbittorrent releases |
| dev | ❌ | Development image |

## Application Setup

The web UI is at `<your-ip>:8080` and a temporary password for the `admin` user will be printed to the container log on startup.

You must then change username/password in the web UI section of settings. If you do not change the password a new one will be generated every time the container starts.

### WEBUI_PORT variable

Due to issues with CSRF and port mapping, should you require to alter the port for the web UI **you need to change both sides of the -p 8080 switch AND set the WEBUI_PORT variable to the new port**.

For example, to set the port to 8090 you need to set -p 8090:8090 and -e WEBUI_PORT=8090

### TORRENTING_PORT

A bittorrent client can be an active or a passive node. Running your client as an active node has the advantage of being able to connect to both active and passive peers, and can potentially increase the number of incoming connections. This requires an open port on the host machine which might differ from container's internal one.

Similarly to the WEBUI_PORT, to set the port to 6887 you need to pass -p 6887:6887, -p 6887:6887/udp and -e TORRENTING_PORT=6887 arguments to Docker.

## Usage

To help you get started creating a container from this image you can either use docker-compose or the docker cli.

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  qbittorrent-vpn:
    image: ghcr.io/clement-brodu/qbittorrent-vpn:latest
    container_name: qbittorrent-vpn
    cap_add:
      - NET_ADMIN
    dns:
      - 8.8.8.8
      - 8.8.4.4
    devices:
      - /dev/net/tun:/dev/net/tun
    environment:
      - VPN_ENABLED=yes
      - LAN_NETWORK=192.168.1.0/24
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - WEBUI_PORT=8080
      - TORRENTING_PORT=6881
    volumes:
      - /path/to/qbittorrent-vpn/appdata:/config
      - /path/to/downloads:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
```

## Parameters

### Environment Variables

| Variable | Required | Function | Example |
|----------|----------|----------|----------|
|`VPN_ENABLED`| Yes | Enable VPN? (yes/no) Default:yes|`VPN_ENABLED=yes`|
|`VPN_USERNAME`| No | If username and password provided, configures ovpn file automatically |`VPN_USERNAME=ad8f64c02a2de`|
|`VPN_PASSWORD`| No | If username and password provided, configures ovpn file automatically |`VPN_PASSWORD=ac98df79ed7fb`|
|`LAN_NETWORK`| Yes | Local Network with CIDR notation |`LAN_NETWORK=192.168.1.0/24`|
|`NAME_SERVERS`| No | Comma delimited name servers |`NAME_SERVERS=8.8.8.8,8.8.4.4`|
|`PUID`| No | UID applied to config files and downloads |`PUID=99`|
|`PGID`| No | GID applied to config files and downloads |`PGID=100`|
|`WEBUI_PORT`| No | Applies WebUI port to qBittorrents config at boot (Must change exposed ports to match)  |`WEBUI_PORT=8080`|
|`TORRENTING_PORT`| No | Applies Incoming port to qBittorrents config at boot (Must change exposed ports to match) |`TORRENTING_PORT=6881`|
|`OUTPUT_POLICY`| No | If OUTPUT_POLICY = ACCEPT, the container wil not drop all IPv4 output traffic (usefull with some private trackers) | `OUTPUT_POLICY=ACCEPT` |

### Volumes

| Volume | Required | Function | Example |
|----------|----------|----------|----------|
| `config` | Yes | qBittorrent and OpenVPN config files | `/your/config/path/:/config`|
| `downloads` | No | Default download path for torrents | `/your/downloads/path/:/downloads`|

### Ports

| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `8080` | TCP | Yes | qBittorrent WebUI | `8080:8080`|
| `6881` | TCP | Yes | qBittorrent listening port | `6881:6881`|
| `6881` | UDP | Yes | qBittorrent listening port | `6881:6881/udp`|

## How to use OpenVPN

The container will fail to boot if `VPN_ENABLED` is set to yes or empty and a .ovpn is not present in the /config/openvpn directory. Drop a .ovpn file from your VPN provider into /config/openvpn and start the container again. You may need to edit the ovpn configuration file to load your VPN credentials from a file by setting `auth-user-pass`.

**Note:** The script will use the first ovpn file it finds in the /config/openvpn directory. Adding multiple ovpn files will not start multiple VPN connections.

### Example auth-user-pass option

`auth-user-pass credentials.conf`

### Example credentials.conf

```txt
username
password
```

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

## Health check

You can add this in your docker-compose to add health check.

```yml
    restart: unless-stopped
    healthcheck:
      test: /etc/scripts/health.sh || exit 1
      interval: 40s
      timeout: 30s
      retries: 3
      start_period: 60s  
```

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (noted in the relevant readme.md), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

* Update images:
    * All images:

        ```bash
        docker-compose pull
        ```

    * Single image:

        ```bash
        docker-compose pull qbittorrent-vpn
        ```

* Update containers:
    * All containers:

        ```bash
        docker-compose up -d
        ```

    * Single container:

        ```bash
        docker-compose up -d qbittorrent-vpn
        ```

* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Image Update Notifications - Diun (Docker Image Update Notifier)

**tip**: We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.

## Thanks & Credits

This project was inspired by [LinuxServer.io](https://www.linuxserver.io/) and all their container.

For the OpenVPN part, this project was inspired by [MarkusMcNugen/docker-qBittorrentvpn](https://github.com/MarkusMcNugen/docker-qBittorrentvpn).
