# Kismet Home Assistant Add-on repository

Third-party **Home Assistant Supervisor** add-on repository that runs [Kismet](https://www.kismetwireless.net/) with **host networking** and **privileged** mode for Wi-Fi monitor mode and optional BLE capture. The Kismet REST API is served on **port 2501** by default.

## Layout

- [`kismet/`](kismet/) — add-on root (`config.yaml`, `Dockerfile`, `run.sh`, …). Supervisor expects **one subdirectory per add-on** when you add this URL as an add-on repository.

## Requirements

- Home Assistant **OS** / **Supervisor** with the add-on store.
- Wi-Fi hardware that supports **monitor mode** on the host (often an external USB adapter).
- For Bluetooth LE capture, a suitable HCI adapter and correct interface name (typically `hci0`).

## Install

1. **Settings → Add-ons → ⋮ → Repositories** → add this Git URL.
2. Find **Kismet Sniffer** in the store under the new section and install it.
3. Configure `wifi_interfaces`, start the add-on, check logs.

Use the companion **ha-kismet-tracker** Home Assistant custom integration (sibling repo in the same mono-project, or your fork) to poll Kismet’s JSON API for whitelisted MAC addresses only.

## Configuration options

| Key | Description |
| --- | --- |
| `wifi_interfaces` | Comma-separated interfaces (e.g. `wlan0`). |
| `enable_ble_capture` | Adds a BLE/HCI capture source when `true`. |
| `ble_interface` | HCI name (default `hci0`). |
| `kismet_additional_args` | Extra CLI flags passed to `kismet`. |

`run.sh` runs `iw dev <iface> set type monitor` before starting Kismet when possible.

## Troubleshooting

- Confirm interfaces exist on the **host** (`ip link`) and support monitor mode.
- Test the API from the host, for example: `curl -sS "http://127.0.0.1:2501/devices/last-time/-1/devices.json"`.
- Some platforms may not ship Kismet packages for every architecture; check add-on build logs if installation fails.

## Security

Prefer restricting access to port 2501 and/or enabling Kismet’s own HTTP authentication if the API is reachable beyond localhost.
