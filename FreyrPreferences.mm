#import "FreyrPreferences.h"

static NSString *const identifier = @"com.phillipt.freyr";

@implementation FreyrPreferences

+(instancetype)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});

	return _sharedObject;
}

-(instancetype)init {
	if (self=[super init]) {
		[self reloadPrefs];
	}
	return self;
}

-(BOOL)boolForKey:(NSString *)key default:(BOOL)defaultVal {
	NSNumber *tempVal = (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	return tempVal ? [tempVal boolValue] : defaultVal;
}

-(NSInteger)intForKey:(NSString *)key default:(NSInteger)defaultVal {
	NSNumber *tempVal = (__bridge NSNumber *)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier);
	return tempVal ? [tempVal intValue] : defaultVal;
}

-(id)objectForKey:(NSString *)key default:(id)defaultVal {
	return (__bridge id)CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)identifier) ?: defaultVal;
}

-(void)reloadPrefs {
	_isEnabled = [self boolForKey:@"enabled" default:YES];
	_isCelsius = [[self objectForKey:@"isCelsius" default:@"fahrenheit"] isEqualToString:@"celsius"];
	_blurStyle = [self intForKey:@"blurStyle" default:2060];
	_isDailyInterval = [[self objectForKey:@"forecastTime" default:@"daily"] isEqualToString:@"daily"];
	_numberOfForecasts = [self intForKey:@"forecastCount" default:4];
}

@end

static void reloadPrefs() {
	[[FreyrPreferences sharedInstance] reloadPrefs];
}

static void __attribute__((constructor)) init() {
	CFNotificationCenterAddObserver (CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, (CFStringRef)[identifier stringByAppendingPathComponent:@"ReloadPrefs"], NULL, 0 );
}