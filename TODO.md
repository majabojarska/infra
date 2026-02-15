# TODO

## Apps

- [x] Setup paperless
- [x] Setup nextcloud
- [x] Setup immich
- [x] Deploy QBittorrent
- [x] Immich HW accel
  - https://immich.app/docs/features/hardware-transcoding/
  - https://nixos.wiki/wiki/Intel_Graphics
  - https://nixos.wiki/wiki/Accelerated_Video_Playback
  - https://wiki.archlinux.org/title/Hardware_video_acceleration#Verification
  - 4h
- [x] Setup home dashboard, e.g. homepage
- [x] Setup adguard on kube
- [x] Setup home assistant
- [x] Setup calibre web
- [x] Setup Esphome
- [x] Add miniflux
- [x] Add freshrss
- [x] Add nextcloud VPS-01
- [x] Setup blog nginx (2h)
  - [x] Service
  - [x] Traefik
  - [x] CI build & deploy
- [ ] Fix paperless link in homepage
- [ ] Setup Authentik
- [ ] Setup Authentik middleware
- [ ] Migration behind Authentik
  - Immich
  - Paperless
  - Miniflux
  - Homeassistant
  - Jellyfin
  - Homepage
  - Actual
- [ ] Setup Homeassistant
- [ ] Point to SearXNG from homepage
- [ ] Setup Renovate
- [ ] Setup copyparty

## Infra

- [x] Setup VPN, Tailscale
  - Subnet routers
  - https://tailscale.com/kb/1019/subnets
  - 4h
- [x] Setup monitoring
  - Prometheus
  - Grafana
  - Alertmanager
- [x] Setup Traefik for reverse proxy with wildcard domain SSL
- [x] Setup cert-manager
- [x] Raspberry Pi 3 node setup
- [x] Setup kubevip
  - 2h
- [x] Setup rpi adguard with sync to master
  - 1h
- [x] Move home DNS to adguard
- [x] Purchase PVE PFsense node
- [x] Setup OPNsense
- [x] Migrate to etcd, setup snapshots
- [x] Move etcd backups to zfs.
  - Move the entire k3s data dir to ZFS `/storage/kubernetes/k3s`
- [x] Setup minimal borgmatic backups to Baczek DC
- [x] Setup redundant backups
  - [x] Setup borg repo on VPS
  - [x] Setup backups to VPS
- [x] Traefik VPS-01
  - [x] Nextcloud on public
- [x] VPS-01 general storage volume
- [ ] Prometheus & Grafana in intranet only
- [ ] NTFY
  - [ ] Setup alerting systems
  - [ ] Setup ntfy on VPS-01, public traefik, authed
  - [ ] Hookup ntfy to ZED
  - [ ] Hookup ntfy to borgmatic
  - [ ] Hookup ntfy as alertmanager receiver
- [ ] Tailscale on OPNsense
- [ ] Setup Bitwarden secrets manager (2h)
  - https://external-secrets.io/latest/provider/bitwarden-secrets-manager/
- [ ] Rework secrets to be based in ESO (4h)
- [ ] Linode + OVH
  1. Terraform the node on Linode
     - Add authorized keys for blog and maja
     - Setup nginx and harden security
  2. Set the A record on OVH
  - 2h

## Meta

- [x] Design backup procedures
  - 2h
- [x] Bitwarden second account for homelab
  - 1h
- [x] Choose DNS/adblock solution - adguard
- [x] RPi ansible playbook
  - 2h
- [ ] Setup infra docs, mdbook?
  - Something with good diagramming capabilities.
  - mkdocs
  - 1h
