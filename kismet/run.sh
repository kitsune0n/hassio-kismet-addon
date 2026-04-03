#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="/data/options.json"
if [[ ! -f "${CONFIG_PATH}" ]]; then
    echo "ERROR: Missing ${CONFIG_PATH}; add-on options not available."
    exit 1
fi

WIFI_IFACES="$(jq -r '.wifi_interfaces // "wlan0"' "${CONFIG_PATH}")"
ENABLE_BLE="$(jq -r '.enable_ble_capture // false' "${CONFIG_PATH}")"
EXTRA_ARGS="$(jq -r '.kismet_additional_args // ""' "${CONFIG_PATH}")"

IFS=',' read -ra IFACE_ARRAY <<< "${WIFI_IFACES// /}"

monitor_iface() {
    local iface="$1"
    echo "INFO: Preparing interface ${iface} for monitor mode..."
    ip link set dev "${iface}" down 2>/dev/null || true
    if iw dev "${iface}" set type monitor 2>/dev/null; then
        ip link set dev "${iface}" up 2>/dev/null || true
        echo "INFO: Interface ${iface} set to monitor mode."
        return 0
    fi
    echo "WARNING: Could not set ${iface} to monitor mode via iw; Kismet may still manage the source."
    ip link set dev "${iface}" up 2>/dev/null || true
    return 0
}

KISMET_SOURCES=()
for raw in "${IFACE_ARRAY[@]}"; do
    iface="${raw// /}"
    [[ -z "${iface}" ]] && continue
    monitor_iface "${iface}"
    KISMET_SOURCES+=("-c" "${iface}")
done

if [[ "${ENABLE_BLE}" == "true" ]]; then
    HCI_DEV="$(jq -r '.ble_interface // "hci0"' "${CONFIG_PATH}")"
    echo "INFO: Adding BLE capture source ${HCI_DEV}."
    KISMET_SOURCES+=("-c" "${HCI_DEV}")
fi

if [[ ${#KISMET_SOURCES[@]} -eq 0 ]]; then
    echo "ERROR: No capture interfaces configured."
    exit 1
fi

# shellcheck disable=SC2086
exec kismet "${KISMET_SOURCES[@]}" ${EXTRA_ARGS}
