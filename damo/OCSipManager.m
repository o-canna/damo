//
//  OCSipManager.m
//  damo
//
//  Created by systec on 2019/7/6.
//  Copyright © 2019 systec. All rights reserved.
//

#import "OCSipManager.h"

#define THIS_FILE "demo"

@interface OCSipManager()

@property (nonatomic, assign) pjsua_acc_id account_id;

@property (nonatomic, assign) pjsua_call_id call_id;

@end

@implementation OCSipManager

static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info) {
    if(info->renew != 0)
    {
        if(info->cbparam->code == 200)
        {
            printf("login successful");
        }
        else
        {
            printf("login failed");
        }
    }
    else
    {
        if(info->cbparam->code == 200)
        {
            printf("logout successful");
        }
        else
        {
            printf("logout failed");
        }
    }
}

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    PJ_LOG(3,(THIS_FILE, "Incoming call from %.*s!!", (int)ci.remote_info.slen, ci.remote_info.ptr));
    
    /* Automatically answer incoming calls with 200/OK */
    //  pjsua_call_answer(call_id, 200, NULL, NULL);
    printf("call_id=%d\n",call_id);
    
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

/* Display error and exit application */
static void error_exit(const char *title, pj_status_t status)
{
    pjsua_perror(THIS_FILE, title, status);
    //    pjsua_destroy();
    //    exit(1);
}


+(instancetype)PjsipManager
{
    static OCSipManager *sipManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sipManager = [[self alloc] init];
    });
    return sipManager;
}

//初始化pjsip
+(BOOL)initPjsip{
    
    pj_status_t status;
    
    //注册线程
    pj_bool_t bool_t = pj_thread_is_registered();
    
    if(!bool_t)
    {
        pj_thread_desc desc;
        pj_thread_t* thread;
        status = pj_thread_register(NULL, desc, &thread);
        if(status != PJ_SUCCESS)
        {
            error_exit("thread registration failed", status);
            return false;
        }
    }
    
    status = pjsua_destroy();
    if(status != PJ_SUCCESS)
    {
        error_exit("destroy failed", status);
        return false;
    }
    
    /* Create pjsua first! */
    status = pjsua_create();
    if (status != PJ_SUCCESS)
    {
        error_exit("Error in pjsua_create()", status);
        return false;
    }
    else
    {
        /* Init pjsua */
        {
            pjsua_config cfg;
            pjsua_logging_config log_cfg;
            
            pjsua_config_default(&cfg);
            cfg.cb.on_reg_state2 = &on_reg_state2;
            cfg.cb.on_incoming_call = &on_incoming_call;
            cfg.cb.on_call_media_state = &on_call_media_state;
            cfg.cb.on_call_state = &on_call_state;
            
            pjsua_logging_config_default(&log_cfg);
            //日志等级 0不打印日志 4打印详细日志
            log_cfg.console_level = 4;
            
            status = pjsua_init(&cfg, &log_cfg, NULL);
            if (status != PJ_SUCCESS)
            {
                error_exit("Error in pjsua_init()", status);
                return false;
            }
        }
    }
    return true;
}

//注册pjsip
-(BOOL)domain:(char *)sip_domain user:(char *)sip_user passwd:(char *)sip_passwd
{
    pj_status_t status;
    /* Add UDP transport. */
    {
        pjsua_transport_config cfg;
        
        pjsua_transport_config_default(&cfg);
        cfg.port = 5060;
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
        if (status != PJ_SUCCESS)
        {
            error_exit("Error creating transport", status);
            return false;
        }
    }
    
    /* Initialization is done, now start pjsua */
    status = pjsua_start();
    if (status != PJ_SUCCESS)
    {
        error_exit("Error starting pjsua", status);
        return false;
    }
    /* Register to SIP server by creating SIP account. */
    {
        pjsua_acc_config cfg;
        
        //        cfg.cred_info[0].realm = pj_str(SIP_DOMAIN);
        
        pjsua_acc_config_default(&cfg);
        char id[60];
        sprintf(id, "sip:%s@%s",sip_user, sip_domain);
        char reg_uri[60];
        sprintf(reg_uri, "sip:%s", sip_domain);
        
        cfg.id = pj_str(id);
        cfg.reg_uri = pj_str(reg_uri);
        cfg.cred_count = 1;
        cfg.cred_info[0].realm = pj_str("*");
        cfg.cred_info[0].scheme = pj_str("digest");
        cfg.cred_info[0].username = pj_str(sip_user);
        cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        cfg.cred_info[0].data = pj_str(sip_passwd);
        
        status = pjsua_acc_add(&cfg, PJ_TRUE, &_account_id);
        
        if (status != PJ_SUCCESS)
        {
            error_exit("Error adding account", status);
            return 1;
        }
    }
    return 0;
}

-(BOOL)accountUnregistered
{
    pj_status_t status;
    
    status = pjsua_acc_del(_account_id);
    
    if (status != PJ_SUCCESS)
    {
        error_exit("Error deleting account", status);
        return false;
    }
    return true;
}

//挂断电话
-(void)hangupCall
{
    //获取账户信息
    pjsua_call_info info;
    pjsua_call_get_info(_account_id, &info);
    
    if(info.media_status == PJSUA_CALL_MEDIA_ACTIVE)
    {
        pjsua_call_hangup_all();
    }
}
// 销毁pjsip
-(BOOL)destroyPjsip
{
    pj_status_t status;
    /* Destroy pjsua */
    status = pjsua_destroy();
    if(status != PJ_SUCCESS)
    {
        error_exit("destroy failed", status);
        return false;
    }
    return true;
}

-(BOOL)devName:(char*) name devSipId:(char*) sip_id sipServer:(char*)sip_server
{
    
    pj_status_t status;
    /* If URL is specified, make call to the URL. */
    char sip_uri[80];
    sprintf(sip_uri, "\"%s\" <sip:%s@%s>",name, sip_id, sip_server);
    pj_str_t uri = pj_str(sip_uri);
    pjsua_call_setting call_set;
    pjsua_call_setting_default(&call_set);
    status = pjsua_call_make_call(_account_id, &uri, &call_set, NULL, NULL, NULL);
    if (status != PJ_SUCCESS)
    {
        error_exit("Error making call", status);
        return false;
    }
    return true;
}

-(void)answerCall{
    pjsua_call_answer(_call_id, 200, NULL, NULL);
}

@end

