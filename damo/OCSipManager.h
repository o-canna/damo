//
//  OCSipManager.h
//  damo
//
//  Created by systec on 2019/7/6.
//  Copyright © 2019 systec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pjsua.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCSipManager : NSObject

+(instancetype)PjsipManager;

+(BOOL)initPjsip;

-(BOOL)domain:(char *)sip_domain user:(char *)sip_user passwd:(char *)sip_passwd;

-(BOOL)devName:(char*) name devSipId:(char*) sip_id sipServer:(char*)sip_server;

-(void)answerCall;

@end

NS_ASSUME_NONNULL_END
