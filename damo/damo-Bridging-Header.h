//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#include "demo.h"
#include "OCSipManager.h"

extern void (^ __nonnull incoming_call)(int acc_id, int call_id);
extern void CFuncTest(int acc_id, int call_id);
