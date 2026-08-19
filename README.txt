C.P Tuya Rain and Lux Sensor v3.5.2

Changes in v3.5:
- Adds an explicit SmartThings device presentation for the dashboard.
- Dashboard summary shows Water + Lux in the same group.
- Battery is excluded from the dashboard summary.
- Battery capability is still kept in the detail view and backend.
- Reuses the existing Driver Information custom capability when available.

Install:
1. Run SETUP-AND-INSTALL.cmd.
2. Force-close and reopen the SmartThings app.
3. If an already-paired device still shows the previous dashboard UI, remove the device and pair it again after installing this build.

Changes in v3.5.2:
- Restores dedicated Tuya EF00 parsing for TS0601 / _TZE200_u6x1zyv2.
- Water state only changes from explicit rain DP values (0=dry, 1=wet).
- Removes generic IAS/default water handling to prevent false wet notifications.
- Adds EF00 DP logging for diagnosis.
