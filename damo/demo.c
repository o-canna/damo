//
//  demo.c
//  Hello
//
//  Created by bluefish on 2019/6/30.
//  Copyright © 2019 bluefish. All rights reserved.
//

#import <pjsua.h>
#include "demo.h"

#define THIS_FILE "demo"

#define SIP_DOMAIN "hk.systec-pbx.net"
#define SIP_USER "00000000000001E6"
#define SIP_PASSWD "063283"

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
  pjsua_call_info ci;

  PJ_UNUSED_ARG(acc_id);
  PJ_UNUSED_ARG(rdata);

  pjsua_call_get_info(call_id, &ci);

  PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!", (int)ci.remote_info.slen, ci.remote_info.ptr));

  /* Automatically answer incoming calls with 200/OK */
  pjsua_call_answer(call_id, 200, NULL, NULL);
}

/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
  pjsua_call_info ci;

  PJ_UNUSED_ARG(e);

  pjsua_call_get_info(call_id, &ci);
  PJ_LOG(3,(THIS_FILE, "Call %d state=%.*s", call_id, (int)ci.state_text.slen, ci.state_text.ptr));
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id) {
  pjsua_call_info ci;

  pjsua_call_get_info(call_id, &ci);

  if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
      // When media is active, connect call to sound device.
      pjsua_conf_connect(ci.conf_slot, 0);
      pjsua_conf_connect(0, ci.conf_slot);
  }
}

void demo() {
    pjsua_acc_id acc_id;
    pj_status_t status;
    
    pjsua_create();
    
    pjsua_config ua_cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;
    
    pjsua_config_default(&ua_cfg);
    ua_cfg.cb.on_incoming_call = &on_incoming_call;
    ua_cfg.cb.on_call_media_state = &on_call_media_state;
    ua_cfg.cb.on_call_state = &on_call_state;
    
    pjsua_logging_config_default(&log_cfg);
    pjsua_media_config_default(&media_cfg);
    
    pjsua_init(&ua_cfg, &log_cfg, &media_cfg);
    
    pjsua_transport_config transportConfig;
    
    pjsua_transport_config_default(&transportConfig);
    
    transportConfig.port = 5062;
    
    pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, NULL);
    // pjsua_transport_create(PJSIP_TRANSPORT_TCP, &transportConfig, NULL);
    
    pjsua_start();
    
    pjsua_acc_config cfg;

#if 1
    pjsua_acc_config_default(&cfg);
    cfg.id = pj_str("sip:" SIP_USER "@" SIP_DOMAIN);
    cfg.reg_uri = pj_str("sip:" SIP_DOMAIN);
    cfg.cred_count = 1;
    cfg.cred_info[0].realm = pj_str("*");
    cfg.cred_info[0].scheme = pj_str("digest");
    cfg.cred_info[0].username = pj_str(SIP_USER);
    cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    cfg.cred_info[0].data = pj_str(SIP_PASSWD);
#else
    pjsua_acc_config_default(&cfg);
//    cfg.id = pj_str("sip:" SIP_USER "@" SIP_DOMAIN);
    cfg.id = pj_str("sip:000@192.168.1.105");
//    cfg.reg_uri = pj_str("sip:" SIP_DOMAIN);
//    cfg.cred_count = 1;
//    cfg.cred_info[0].realm = pj_str("*");
//    cfg.cred_info[0].scheme = pj_str("digest");
//    cfg.cred_info[0].username = pj_str(SIP_USER);
//    cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
//    cfg.cred_info[0].data = pj_str(SIP_PASSWD);
#endif
//
    status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
//    if (status != PJ_SUCCESS) error_exit("Error adding account", status);
}
