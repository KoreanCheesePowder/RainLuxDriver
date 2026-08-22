local capabilities = require "st.capabilities"
local ZigbeeDriver = require "st.zigbee"
local log = require "log"
local clusters = require "st.zigbee.zcl.clusters"

local CLUSTER_TUYA = 0xEF00
local driver_info = capabilities["buildbook37604.driverInformation"]
local IlluminanceMeasurement = clusters.IlluminanceMeasurement

-- HOBEIAN ZG-223Z / _TZE200_u6x1zyv2
-- Tuya EF00 payload: [transIdHi transIdLo] [dp] [type] [lenHi lenLo] [data...]
-- We intentionally DO NOT register SmartThings' generic waterSensor Zigbee handler.
-- This TS0601 reports through manufacturer cluster 0xEF00; letting the generic
-- IAS/default handler decide wet/dry can create false wet events.

local function emit_driver_info(device)
  if driver_info ~= nil then
    device:emit_event(driver_info.author("치즈가루"))
    device:emit_event(driver_info.driverVersion("v3.5.6"))
  end
end

local function bytes_to_uint(body, start_index, length)
  local value = 0
  for i = 0, length - 1 do
    local b = body:byte(start_index + i)
    if b == nil then return nil end
    value = (value * 256) + b
  end
  return value
end

local function dp_value(body, data_type, start_index, length)
  if length <= 0 then return nil end
  if data_type == 0x01 or data_type == 0x04 or data_type == 0x05 then
    return body:byte(start_index)
  elseif data_type == 0x02 then
    return bytes_to_uint(body, start_index, length)
  end
  return nil
end

-- Publish the Tuya DP1 water state immediately so SmartThings routines can react.
-- Duplicate reports are suppressed, but a real dry<->wet transition is never delayed.
local function emit_rain(device, raw)
  if raw ~= 0 and raw ~= 1 then
    log.warn(string.format("ZG-223Z rain DP ignored unexpected value=%s", tostring(raw)))
    return
  end

  local previous = device:get_field("rain_raw")
  device:set_field("rain_raw", raw)

  if previous == raw then
    log.debug(string.format("ZG-223Z rain DP duplicate ignored value=%d", raw))
    return
  end

  if raw == 1 then
    log.warn("ZG-223Z rain DP: WET (1); emitting immediately")
    device:emit_event(capabilities.waterSensor.water.wet())
  else
    log.info("ZG-223Z rain DP: DRY (0); emitting immediately")
    device:emit_event(capabilities.waterSensor.water.dry())
  end
end

local function emit_lux(device, raw)
  if raw == nil then return end
  if raw < 0 then raw = 0 end
  -- ZG-223Z reports illuminance as a numeric Tuya DP. Keep raw lux here.
  device:emit_event(capabilities.illuminanceMeasurement.illuminance(raw))
end

local function emit_battery(device, raw)
  if raw == nil then return end
  if raw < 0 then raw = 0 end
  if raw > 100 then raw = 100 end
  device:emit_event(capabilities.battery.battery(raw))
end

local function handle_dp(device, dp, data_type, raw)
  log.info(string.format("ZG-223Z EF00 dp=%d type=%d value=%s", dp, data_type, tostring(raw)))

  -- Known ZG-223Z datapoints used by this driver.
  if dp == 1 then
    emit_rain(device, raw)
  elseif dp == 2 or dp == 102 then
    -- ZG-223Z variants report lux on DP102; older variants may use DP2.
    emit_lux(device, raw)
  elseif dp == 4 then
    emit_battery(device, raw)
  else
    -- Sensitivity / sampling / firmware-specific values are diagnostic only here.
    -- Do not map an unknown DP to waterSensor.
    log.debug(string.format("ZG-223Z unhandled dp=%d value=%s", dp, tostring(raw)))
  end
end

local function tuya_command_handler(driver, device, zb_rx)
  local body = zb_rx.body and zb_rx.body.zcl_body and zb_rx.body.zcl_body.body_bytes
  if body == nil then
    log.warn("ZG-223Z EF00 message without GenericBody")
    return
  end

  local n = #body
  if n < 7 then
    log.warn(string.format("ZG-223Z short EF00 payload len=%d", n))
    return
  end

  -- First two bytes are Tuya transaction/status sequence bytes.
  local pos = 3
  while pos + 3 <= n do
    local dp = body:byte(pos)
    local data_type = body:byte(pos + 1)
    local len_hi = body:byte(pos + 2)
    local len_lo = body:byte(pos + 3)
    if dp == nil or data_type == nil or len_hi == nil or len_lo == nil then break end

    local data_len = (len_hi * 256) + len_lo
    local data_start = pos + 4
    if data_len <= 0 or data_start + data_len - 1 > n then
      log.warn(string.format("ZG-223Z invalid EF00 DP frame dp=%d len=%d payload=%d", dp, data_len, n))
      break
    end

    local raw = dp_value(body, data_type, data_start, data_len)
    handle_dp(device, dp, data_type, raw)
    pos = data_start + data_len
  end
end


local function illuminance_attribute_handler(driver, device, value, zb_rx)
  local measured = value and value.value
  if measured == nil or measured == 0xFFFF then return end

  -- Zigbee IlluminanceMeasurement.MeasuredValue uses 10,000 * log10(lux) + 1.
  local lux = math.floor((10 ^ ((measured - 1) / 10000)) + 0.5)
  log.info(string.format("ZG-223Z IlluminanceMeasurement raw=%d lux=%d", measured, lux))
  emit_lux(device, lux)
end

local function added_handler(driver, device)
  -- Do not invent a sensor state at pairing time; wait for the first explicit DP1 report.
  device:set_field("rain_raw", nil)
  emit_driver_info(device)
end

local function init_handler(driver, device)
  emit_driver_info(device)
end

local function do_configure_handler(driver, device)
  -- TS0601 is EF00 based; generic IAS enrollment is intentionally not used.
  emit_driver_info(device)
end

local driver_template = {
  supported_capabilities = {
    capabilities.waterSensor,
    capabilities.illuminanceMeasurement,
    capabilities.battery,
    capabilities.refresh,
    driver_info
  },

  zigbee_handlers = {
    cluster = {
      [CLUSTER_TUYA] = {
        [0x01] = tuya_command_handler,
        [0x02] = tuya_command_handler
      }
    },
    attr = {
      [IlluminanceMeasurement.ID] = {
        [IlluminanceMeasurement.attributes.MeasuredValue.ID] = illuminance_attribute_handler
      }
    }
  },

  lifecycle_handlers = {
    added = added_handler,
    init = init_handler,
    doConfigure = do_configure_handler
  },

  health_check = false
}

local driver = ZigbeeDriver("tuya-rain-lux-sensor", driver_template)
driver:run()
