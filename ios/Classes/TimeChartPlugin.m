#import "TimeChartPlugin.h"
#if __has_include(<time_chart/time_chart-Swift.h>)
#import <time_chart/time_chart-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "time_chart-Swift.h"
#endif

@implementation TimeChartPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTimeChartPlugin registerWithRegistrar:registrar];
}
@end
