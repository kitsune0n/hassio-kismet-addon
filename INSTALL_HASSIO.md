# Quick start on Home Assistant (Supervisor / HA OS)

Use branch **`dev`** until it is merged to `main` (GitHub: **Settings → General → Default branch**, or merge `dev` → `main`).

## 1. Add-on Kismet

Requires a **64-bit** Home Assistant OS install (**aarch64** or **amd64**). Kismet’s Debian Bookworm packages are not published for 32-bit Supervisor targets.

1. **Settings → Add-ons →** (three dots) **Repositories**.
2. Add: `https://github.com/kitsune0n/hassio-kismet-addon`
3. **Add-on store** → refresh → install **Kismet Sniffer** (folder `kismet/` in repo).
4. **Configuration:** set `wifi_interfaces` (e.g. `wlan0`). Enable BLE only if you use `hci0` (or adjust `ble_interface`).
5. **Start** the add-on; open **Log** and confirm Kismet starts without fatal errors.
6. **Open Web UI** on the add-on card (native Kismet UI on port **2501**). Default login is **admin** / **admin** (change in add-on options); the wizard is skipped via generated `kismet_site.conf`.
7. **API:** Kismet listens on **2501/tcp** on the **host**. From another machine: `http://<HA_LAN_IP>:2501/` (or `GET .../devices/last-time/-1/devices.json`).

**Wi‑Fi:** use real interface names from the host (`ip link` over SSH); **`wlan0` is often wrong**. You need hardware/drivers that support **monitor mode** (often an external USB adapter).

**Persistence:** Kismet home config is under add-on **`/data/kismet_home`** (HTTP users, UUID), so it survives image updates.

## 2. Integration Kismet Tracker

### Via HACS (recommended)

1. **HACS →** three dots **→ Custom repositories** → Category **Integration** → add  
   `https://github.com/kitsune0n/ha-kismet-tracker`
2. **HACS → Integrations** → find **Kismet Tracker** → **Download** (pick branch `dev` if HACS offers it).
3. **Restart Home Assistant.**

### Manual

Copy `custom_components/kismet_tracker` into `/config/custom_components/`, restart HA.

## 3. Add the integration in UI

1. **Settings → Devices & services → Add integration** → **Kismet Tracker**.
2. **Host:** use the address where **Home Assistant Core** can reach Kismet on port **2501**.  
   - Usually the **LAN IP** of your HA machine (e.g. `192.168.1.50`).  
   - Avoid `127.0.0.1` from Core unless you know your network setup; host-network add-ons bind on the host, not inside the Core container.
3. **Port:** `2501` (unless you changed it in Kismet).
4. **Allow list:** only MACs you want as `device_tracker` (comma or newline).
5. Finish the flow; tune **Options** (poll interval, away timeout, RSSI, optional “recent RF devices” sensor).

## 4. Unprotected mode for full hardware access

This app uses `full_access: true` for Wi‑Fi/BLE capture. After install, you may need to **disable Protected mode** for the app in the info panel so full access is applied (Supervisor only applies full device access when not protected). Use only if you trust this image.

## 5. Add-on does not appear in the store

- **Architecture:** this add-on is **aarch64** and **amd64** only (Kismet Bookworm repo). 32-bit HA installs are not supported.
- **Reload:** **Settings → Add-ons →** (store) refresh the page; or restart the **Supervisor** host from **Developer tools** if you use it.
- **Stale git clone:** Remove the custom repository URL, save, add it again so the supervisor re-clones the repo.

## 6. Push / branch reminder

After `git push origin dev`, either set **default branch** to `dev` on GitHub for these repos or merge `dev` into `main` so the Add-on store and HACS see the latest code on the default branch.
