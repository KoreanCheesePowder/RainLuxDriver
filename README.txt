C.P 비 및 조도 센서 v3.5.9

Author shown in SmartThings details: 치즈가루
SmartThings 상세정보 표시 버전: v3.5.9

v3.5.9 변경사항:
- DP1 WET 신호를 30초 연속 유지할 때만 waterSensor=wet 이벤트 발생.
- 짧은 WET 오검출은 SmartThings 알림/루틴으로 전달하지 않음.
- DRY는 즉시 반영하고 진행 중인 WET 확인을 자동 취소.
- 동일 DP 중복 보고 억제 유지.
- Lux / Battery / 대시보드 구성 유지.
- 제작자: 치즈가루.

Install:
1. Run SETUP-AND-INSTALL.cmd.
2. Select the requested SmartThings channel/hub if prompted.
3. Force-close and reopen the SmartThings app.
4. Run SmartThings Edge logcat and verify WET candidate / WET confirmed / DRY events.
