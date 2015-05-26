#import "Interfaces.h"

@interface FreyrForecast : NSObject
@property (nonatomic, retain, setter=setDayForecasts:) NSArray* dayForecasts;
@property (nonatomic, assign) CGFloat averageTemperature;
+(id)sharedInstance;
+(FreyrForecast*)forecastFromDayForecast:(id)dayForecast;
-(void)calculateForecast;
-(NSArray*)getForecastForNumberOfDays:(int)days;
-(void)setDayForecasts:(NSArray*)dayForecasts;
@end