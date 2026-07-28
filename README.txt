# RainLuxDriver

SmartThings Edge Driver collection developed by **CheesePowder**.

Currently supported driver:

- 🌧️ Tuya Rain & Illuminance Sensor (TS0601)

---

# Features

- Local SmartThings Edge Driver
- Rain Detection (Wet / Dry)
- Illuminance Measurement (Lux)
- Driver Information Capability
- Automatic device fingerprint detection

---

# Supported Devices

| Manufacturer | Model |
|--------------|-------|
| `_TZE200_u6x1zyv2` | `TS0601` |

More devices will be added in future releases.

---

# Installation

## 1. Join the Driver Channel

Click the invitation link below and join the **CheesePowder** Driver Channel.

https://bestow-regional.api.smartthings.com/invite/BxlrP0QErvMP

---

## 2. Install the Driver

After joining the channel,

1. Open **SmartThings App**
2. Select your **Hub**
3. Install **CheesePowder** Driver
4. Wait a few moments

---

## 3. Pair the Device

Put your device into pairing mode.

The driver will automatically recognize supported devices.

---

# Device Capabilities

- Water Sensor
- Illuminance Measurement
- Driver Information

---

# Repository Structure

```
RainLuxDriver
│
├── README.md
└── TuyaRainLux
    ├── custom-capability
    ├── profiles
    ├── src
    ├── templates
    ├── config.yml
    ├── fingerprints.yml
    └── SETUP-AND-INSTALL.ps1
```

---

# Driver Information

| Item | Value |
|------|-------|
| Driver | Tuya Rain & Illuminance Sensor |
| Version | v1.0.0 |
| Developer | CheesePowder |
| Platform | SmartThings Edge |

---

# Roadmap

Planned drivers:

- Tuya Motion Sensor
- Tuya Temperature & Humidity Sensor
- Tuya Water Leak Sensor
- Tuya Contact Sensor
- Aqara Device Drivers

---

# Issues

If you find a bug or have a feature request, please open an Issue on GitHub.

https://github.com/KoreanCheesePowder/RainLuxDriver/issues

---

# License

MIT License

Copyright (c) 2026 CheesePowder
