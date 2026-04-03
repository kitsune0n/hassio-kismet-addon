# Kismet Home Assistant Add-on repository

Third-party **Home Assistant Supervisor** add-on repository that runs [Kismet](https://www.kismetwireless.net/) with **host networking** and **privileged** mode for Wi-Fi monitor mode and optional BLE capture. The Kismet REST API is served on **port 2501** by default.

## Layout

- [`kismet/`](kismet/) — add-on root (`config.yaml`, `Dockerfile`, `run.sh`, …). Supervisor expects **one subdirectory per add-on** when you add this URL as an add-on repository.

## Requirements

- Home Assistant **OS** / **Supervisor** with the add-on store on **aarch64** or **amd64**. (The Kismet Bookworm APT repo does not publish armv7/armhf/i386.)
- Wi-Fi hardware that supports **monitor mode** on the host (often an external USB adapter).
- For Bluetooth LE capture, a suitable HCI adapter and correct interface name (typically `hci0`).

The image installs `kismet-core`, `kismet-capture-linux-wifi`, `kismet-capture-linux-bluetooth`, and `kismet-logtools` — not the `kismet` metapackage (it can depend on optional drivers such as Hak5 Wi-Fi Coconut that are not installable everywhere).

## Install

1. **Settings → Add-ons → ⋮ → Repositories** → add this Git URL.
2. Find **Kismet Sniffer** in the store under the new section and install it.
3. Configure **Wi-Fi interfaces** (see below); **HTTP username/password** default to **admin / admin** so the native Web UI skips the first-run wizard — change them in add-on options if needed, then start the add-on.
4. Use **Open Web UI** on the add-on card to open the standard Kismet dashboard (`http://<host>:2501`).

Use the companion **ha-kismet-tracker** Home Assistant custom integration (sibling repo in the same mono-project, or your fork) to poll Kismet’s JSON API for whitelisted MAC addresses only.

## Configuration options

| Key | Description |
| --- | --- |
| `wifi_interfaces` | Comma-separated interfaces. **Must match a Wi-Fi interface on the HA host** (`ip link` / `iw dev` via SSH). The default `wlan0` is often wrong (many boards use `wlp…` or `wlan1`). |
| `enable_ble_capture` | Adds a BLE/HCI capture source when `true`. |
| `ble_interface` | HCI name (default `hci0`). |
| `kismet_additional_args` | Extra CLI flags passed to `kismet`. |
| `http_username` / `http_password` | Default **admin / admin**. Written to `kismet_site.conf` under `/data/kismet_home/.kismet` on each start. Empty option fields fall back to admin/admin. Kismet does not document a no-login mode. |

`run.sh` sets `HOME=/data/kismet_home` so Kismet config and logs survive rebuilds. It uses `type=linuxwifi` on the command line for each Wi-Fi source, runs `rfkill unblock`, logs `ip -br link` at startup, and runs `iw dev <iface> set type monitor` when possible.

### “Unable to find driver for …” / capture fails

- Wrong interface name (most common).
- Chipset/driver without mac80211 monitor mode (many built-in Pi Wi-Fi chips need an external USB adapter with a known-good driver).
- Interface still **managed** by host NetworkManager — may need to take it down on the host or use a dedicated USB radio for capture only.

## Troubleshooting

- Confirm interfaces exist on the **host** (`ip link`) and support monitor mode.
- Test the API from the host, for example: `curl -sS "http://127.0.0.1:2501/devices/last-time/-1/devices.json"`.
- Some platforms may not ship Kismet packages for every architecture; check add-on build logs if installation fails.

## Security

Restrict access to port **2501** (firewall/VLAN). The default **admin/admin** credentials are convenient on a trusted LAN only — use strong unique values if the Web UI or API may be reachable from untrusted networks.
