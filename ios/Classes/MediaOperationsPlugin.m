#import "MediaOperationsPlugin.h"
#import <media_operations/media_operations-Swift.h>

@implementation MediaOperationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMediaOperationsPlugin registerWithRegistrar:registrar];
}
@end
