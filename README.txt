C.P 비 및 조도 센서 v3.5.6

Author shown in SmartThings details: 치즈가루
SmartThings 상세정보 표시 버전: v3.5.6

v3.5.6 변경사항:
- Fixes waterSensor routine triggers: DP1 wet/dry transitions are emitted immediately.
- Removes the broken 10-second wet confirmation behavior that could suppress real wet events.
- Suppresses only duplicate DP1 reports, not real state changes.
- Fixes illuminance routine triggers for ZG-223Z units reporting Lux on Tuya DP102.
- Also handles the standard Zigbee IlluminanceMeasurement MeasuredValue attribute.
- Keeps Water + Lux dashboard summary.
- Keeps Battery in device details but not in dashboard summary.
- Author is displayed as 치즈가루.

Install:
1. Run SETUP-AND-INSTALL.cmd.
2. Select the requested SmartThings channel/hub if prompted.
3. Force-close and reopen the SmartThings app.
4. Run SmartThings Edge logcat and verify WET/DRY and Lux emitting events.
