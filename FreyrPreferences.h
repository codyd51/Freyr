@interface FreyrPreferences : NSObject
@property(nonatomic, readonly) BOOL isEnabled;
@property(nonatomic, readonly) BOOL isCelsius;
@property(nonatomic, readonly) BOOL isDailyInterval;
@property(nonatomic, readonly) NSInteger blurStyle;
@property(nonatomic, readonly) NSInteger numberOfForecasts;
+(instancetype)sharedInstance;
-(BOOL)boolForKey:(NSString *)key default:(BOOL)defaultVal;
-(NSInteger)intForKey:(NSString *)key default:(NSInteger)defaultVal;
@end