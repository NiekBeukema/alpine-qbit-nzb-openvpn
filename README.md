# [🐋 Alpine qBittorrent nzbget OpenVPN](https://github.com/riboyama/alpine-qbit-nzb-openvpn)

This repository contains the code to build a docker container with nzbget and the [qBittorrent](https://www.qbittorrent.org/) torrent client with all traffic routed through an OpenVPN tunnel with firewall rules preventing traffic outside of the tunnel.
The container is built automatically whenever the Alpine container is updated, the final image is available on the [docker hub](https://hub.docker.com/r/guillaumedsde/alpine-qbittorrent-openvpn).

This container is based on an [Alpine Linux](https://hub.docker.com/_/alpine) and uses the [S6-overlay](https://github.com/just-containers/s6-overlay) for starting setting up the firewall, VPN tunnel and lastly starting qBittorrent.
The image aims to be safe, small and generally minimal by installing as little dependencies as possible and running qBittorrent and OpenVPN as different unprivileged users.

## ✔️ Features summary

- 🏔️ Alpine Linux small and secure base Docker image
- 🤏 As few Docker layers as possible
- 🛡️ Minimal software dependencies installed
- 🛡️ Runs as unprivileged user with minimal permissions
- 🖥️ Built for many platforms
- 🚇 Compatible with most OpenVPN providers
- ↔️ Port forwarding support for PrivateVPN, Private Internet Access and Perfect Privacy

## 🏁 How to Run

### `docker run`

```bash
$ docker run --cap-add=NET_ADMIN -d \
              -v /your/storage/path/:/downloads \
              -v /path/to/config/directory:/config \
              -v /etc/localtime:/etc/localtime:ro \
              -e OPENVPN_PROVIDER=PIA \
              -e OPENVPN_CONFIG=ca_toronto \
              -e OPENVPN_USERNAME=user \
              -e OPENVPN_PASSWORD=pass \
              -e PUID=1000 \
              -e PGID=1000 \
              -e LAN=192.168.0.0/16 \
              -p 8080:8080 \
              -p 6789:6789 \
              riboyama/alpine-qbit-nzb-openvpn:latest
```

### `docker-compose.yml`

```yaml
version: "3.3"
services:
  alpine-qbittorrent-openvpn:
    volumes:
      - "/your/storage/path/:/downloads"
      - "/path/to/config/directory:/config"
      - "/etc/localtime:/etc/localtime:ro"
    environment:
      - OPENVPN_PROVIDER=PIA
      - OPENVPN_CONFIG=ca_toronto
      - OPENVPN_USERNAME=user
      - OPENVPN_PASSWORD=pass
      - PUID=1000
      - PGID=1000
      - LAN=192.168.0.0/16
    ports:
      - "8080:8080"
      - "6789:6789"
    cap_add:
      - NET_ADMIN
    image: riboyama/alpine-qbit-nzb-openvpn:latest
```

## 🖥️ Supported platforms

This container is built for many hardware platforms (yes, even ppc64le whoever uses that... 😉):

- linux/386
- linux/amd64
- linux/arm/v6
- linux/arm/v7
- linux/arm64
- linux/ppc64le

All you have to do is use a recent version of docker and it will pull the appropriate version of the image [guillaumedsde/alpine-qbittorrent-openvpn](https://hub.docker.com/repository/docker/guillaumedsde/alpine-qbittorrent-openvpn) from the docker hub.

## 🚇 OpenVPN configuration

### Officially supported

This image makes use of the [VPN providers'](https://haugene.github.io/docker-transmission-openvpn/supported-providers/) OpenVPN configurations from the latest version of [haugene/docker-transmission-openvpn](https://github.com/haugene/docker-transmission-openvpn/) cheers to that project 🍺!
It is possible I might have messed something up, so if one provider is not working for you, make sure to [leave an issue](https://github.com/guillaumedsde/alpine-qbittorrent-openvpn/issues/new/choose) on this repository's Github page.
Selecting a preloaded configuration works the same way as the haugene container (see below for an example).

### Custom OpenVPN config

If your provider is not in the supported list or if is currently not working, you can mount your `.ovpn` file at `/config/openvpn/config.ovpn` optionally set your `OPENVPN_USERNAME` and `OPENVPN_PASSWORD` leaving the `OPENVPN_PROVIDER` empty and the container will load your configuration upon start.

## 🔍 qBittorrent torrent search

In order to be as light as possible, the `latest` tagged docker image does not include python.
This means that in order to use [qBittorrent's torrent Search functionality](https://www.ghacks.net/2018/11/19/searching-torrents-from-within-qbittorrent/) you have to use the version of this image based on the official python alpine docker image, this image is tagged `python`, in order to download it, please use `guillaumedsde/alpine-qbittorrent-openvpn:python`.

## 🐌 Limitations

This image has a couple of limitations:

- **No IPv6 support** I have not installed iptables for IPv6 as such the firewall kill switch will probably not work with IPv6 (I have not tested it) if you need it, [file an issue](https://github.com/guillaumedsde/alpine-qbittorrent-openvpn/issues/new/choose) and I'll look into it when I have some time
- **No support for docker's built in DNS server** Docker has an embedded DNS server that containers query to get the IPs of other containers, however, Docker does some [weird](https://stackoverflow.com/a/50730336) [iptables](https://stackoverflow.com/questions/41707573/how-does-docker-embedded-dns-resolver-work/50730336) trick to redirect containers' DNS requests to its resolver at `127.0.0.11`. I have not managed to write proper iptables rules to allow this traffic, if you have any idea how, [leave an issue](https://github.com/guillaumedsde/alpine-qbittorrent-openvpn/issues/new/choose) 🙂. In the meantime, the container's DNS resolver is set using the `DNS` environment variable

## Enhancements

[@reconman](https://github.com/reconman) suggests using [docker-autoheal](https://github.com/willfarrell/docker-autoheal) by adding the `autoheal=true` label to the container to automatically restart it when the container becomes unhealthy (qBittorrent or OpenVPN crashes).

## 🙏 Credits

A couple of projects really helped me out while developing this container:

- 🍻 [0x022b/s6-openvpn](https://github.com/0x022b/s6-openvpn) for figuring out how the S6 overlay works, and for most of the code to run OpenVPN as an unprivileged user
- 🍻 [haugene/docker-transmission-openvpn](https://github.com/haugene/docker-transmission-openvpn) for general inspiration for the project and specifically, the OpenVPN configurations, the port forwarding and healthcheck scripts adapted in this repository
- 🏁 [s6-overlay](https://github.com/just-containers/s6-overlay) A simple, relatively small yet powerful set of init script for managing processes (especially in docker containers)
- 🏔️ [Alpine Linux](https://alpinelinux.org/) an awesome lightweight secure linux distribution used as the base for this container
- 🐋 The [Docker](https://github.com/docker) project (of course)
