local capabilities = require "st.capabilities"
local ZigbeeDriver = require "st.zigbee"
local defaults = require "st.zigbee.defaults"
local constants = require "st.zigbee.constants"

local driver_info = capabilities["buildbook37604.driverInformation"]

local function emit_driver_info(device)
  if driver_info ~= nil then
    device:emit_event(driver_info.author("치즈가루"))
    device:emit_event(driver_info.driverVersion("v1.0.0"))
  end
end

local function added_handler(driver, device)
  device:emit_event(capabilities.waterSensor.water.dry())
  emit_driver_info(device)
end

local function init_handler(driver, device)
  emit_driver_info(device)
end

local function do_configure_handler(driver, device)
  device:configure()
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

  lifecycle_handlers = {
    added = added_handler,
    init = init_handler,
    doConfigure = do_configure_handler
  },

  ias_zone_configuration_method = constants.IAS_ZONE_CONFIGURE_TYPE.AUTO_ENROLL_RESPONSE,
  health_check = false
}

defaults.register_for_default_handlers(
  driver_template,
  driver_template.supported_capabilities
)

local driver = ZigbeeDriver("tuya-rain-lux-sensor", driver_template)
driver:run()
