//
//  demo.h
//  Hello
//
//  Created by bluefish on 2019/6/30.
//  Copyright © 2019 bluefish. All rights reserved.
//

#ifndef demo_h
#define demo_h

#import <pjsua.h>
#include <stdio.h>

typedef enum SIPSTATE{
    CTL_ACC_REGISTER=0,
    CTL_MAKE_CALL,
    CTL_OPEN_DOOR
}UASTATE;

int init_pjsip(void);
int account_registered(char *sip_domain, char *sip_user, char *sip_passwd);
int account_unregistered(void);
void make_call(char* name, char* sip_id, char* sip_server);
void answer(int call_id);
int destroy_pjsip(void);
void hang_up_call(void);

#endif /* demo_h */
