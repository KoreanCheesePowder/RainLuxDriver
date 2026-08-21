C.P Tuya Rain and Lux Sensor v3.5.4

HOBEIAN ZG-223Z / _TZE200_u6x1zyv2용 SmartThings Zigbee Edge 드라이버입니다. Tuya 0xEF00 데이터 포인트를 직접 해석해 강우, 조도와 배터리 상태를 제공합니다.

주요 기능
- DP1 강우 상태를 waterSensor로 표시
- DP2 원시 조도값을 illuminanceMeasurement로 표시
- DP4 배터리값을 0~100% 범위로 보정해 표시
- 순간적인 오감지를 줄이기 위해 DP1=1이 10초 동안 유지될 때만 wet 발행
- DP1=0 수신 시 대기 중인 wet 확인을 취소하고 dry 즉시 발행
- 알 수 없는 데이터 포인트를 강우 상태로 잘못 매핑하지 않음
- 대시보드에 Water + Lux 요약 표시
- 상세 화면에 Battery, refresh, Driver Information 표시

설치
1. SETUP-AND-INSTALL.cmd를 실행합니다.
2. 안내가 표시되면 SmartThings 채널과 허브를 선택합니다.
3. SmartThings 앱을 완전히 종료한 뒤 다시 실행합니다.

드라이버 정보
- 제작자: 치즈가루
- 버전: v3.5.4
- packageKey: tuya-rain-lux-sensor
