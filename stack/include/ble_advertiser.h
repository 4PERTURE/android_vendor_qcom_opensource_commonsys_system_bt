/******************************************************************************
 *
 *  Copyright (C) 2016 The Android Open Source Project
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at:
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 ******************************************************************************/

#ifndef BLE_ADVERTISER_H
#define BLE_ADVERTISER_H

#include <base/bind.h>
#include <vector>
#include "btm_ble_api.h"

#define BTM_BLE_MULTI_ADV_SUCCESS 0
#define BTM_BLE_MULTI_ADV_FAILURE 1
#define ADVERTISE_FAILED_TOO_MANY_ADVERTISERS 0x02

using MultiAdvCb = base::Callback<void(uint8_t /* status */)>;

// methods we must have defined
void btm_ble_update_dmt_flag_bits(uint8_t* flag_value,
                                  const uint16_t connect_mode,
                                  const uint16_t disc_mode);
void btm_acl_update_conn_addr(uint8_t conn_handle, BD_ADDR address);

// methods we expose to c code:
void btm_ble_multi_adv_cleanup(void);
void btm_ble_multi_adv_init();

typedef struct {
  uint16_t advertising_event_properties;
  uint32_t adv_int_min;
  uint32_t adv_int_max;
  tBTM_BLE_ADV_CHNL_MAP channel_map;
  tBTM_BLE_AFP adv_filter_policy;
  int8_t tx_power;
  uint8_t primary_advertising_phy;
  uint8_t secondary_advertising_phy;
  uint8_t scan_request_notification_enable;
} tBTM_BLE_ADV_PARAMS;

class BleAdvertiserHciInterface;

class BleAdvertisingManager {
 public:
  virtual ~BleAdvertisingManager() = default;

  static const uint16_t advertising_prop_legacy_connectable = 0x0011;
  static const uint16_t advertising_prop_legacy_non_connectable = 0x0010;

  static void Initialize(BleAdvertiserHciInterface* interface);
  static void CleanUp();
  static BleAdvertisingManager* Get();

  /* Register an advertising instance, status will be returned in |cb|
  * callback, with assigned id, if operation succeeds. Instance is freed when
  * advertising is disabled by calling |BTM_BleDisableAdvInstance|, or when any
  * of the operations fails.
  * The instance will have data set to |advertise_data|, scan response set to
  * |scan_response_data|, and will be enabled.
  */
  virtual void StartAdvertising(uint8_t advertiser_id, MultiAdvCb cb,
                                tBTM_BLE_ADV_PARAMS* params,
                                std::vector<uint8_t> advertise_data,
                                std::vector<uint8_t> scan_response_data,
                                int timeout_s, MultiAdvCb timeout_cb) = 0;

  /* Register an advertising instance, status will be returned in |cb|
  * callback, with assigned id, if operation succeeds. Instance is freed when
  * advertising is disabled by calling |BTM_BleDisableAdvInstance|, or when any
  * of the operations fails. */
  virtual void RegisterAdvertiser(
      base::Callback<void(uint8_t /* inst_id */, uint8_t /* status */)>) = 0;

  /* This function enables/disables an advertising instance. Operation status is
   * returned in |cb| */
  virtual void Enable(uint8_t inst_id, bool enable, MultiAdvCb cb,
                      int timeout_s, MultiAdvCb timeout_cb) = 0;

  /* This function update a Multi-ADV instance with the specififed adv
   * parameters. */
  virtual void SetParameters(uint8_t inst_id, tBTM_BLE_ADV_PARAMS* p_params,
                             MultiAdvCb cb) = 0;

  /* This function configure a Multi-ADV instance with the specified adv data or
   * scan response data.*/
  virtual void SetData(uint8_t inst_id, bool is_scan_rsp,
                       std::vector<uint8_t> data, MultiAdvCb cb) = 0;

  /*  This function disable a Multi-ADV instance */
  virtual void Unregister(uint8_t inst_id) = 0;

  /* This method is a member of BleAdvertiserHciInterface, and is exposed here
   * just for tests. It should never be called from upper layers*/
  virtual void OnAdvertisingSetTerminated(
      uint8_t status, uint8_t advertising_handle, uint16_t connection_handle,
      uint8_t num_completed_extended_adv_events) = 0;
};

#endif  // BLE_ADVERTISER_H
