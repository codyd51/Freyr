#import "FreyrForecast.h"
#import "FreyrPreferences.h"

@implementation FreyrForecast
+ (id)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});

	return _sharedObject;
}
-(id)init {
	if ((self = [super init])) {
		_dayForecasts = [[NSArray alloc] init];
	}
	return self;
}
+(FreyrForecast*)forecastFromDayForecast:(DayForecast*)dayForecast {
	FreyrForecast* forecast = [[FreyrForecast alloc] init];
	forecast.averageTemperature = ([dayForecast.high floatValue]+ [dayForecast.low floatValue]) / 2;

	return forecast;
}
-(void)calculateForecast {
	WeatherPreferences* prefs = [objc_getClass("WeatherPreferences") sharedPreferences];
    City* city = [prefs localWeatherCity];

	NSArray* daysOrHours;

    if ([[FreyrPreferences sharedInstance] isDailyInterval]) {
        daysOrHours = city.dayForecasts;
    }
    else {
        daysOrHours = city.hourlyForecasts;
    }
    
    NSMutableArray* keys = [[NSMutableArray alloc] init];

    //We start at index 1 because 0 is today
    for (int i = 1; i < daysOrHours.count; i++) {
    	if ([[FreyrPreferences sharedInstance] isDailyInterval]) {
        	DayForecast* fore = daysOrHours[i];
        	NSLog(@"day[%i]: %f", i, (([fore.high floatValue] + [fore.low floatValue])/2));

        	BOOL isCelsius = [[FreyrPreferences sharedInstance] isCelsius];
        	CGFloat celTemp = ([fore.high floatValue] + [fore.low floatValue])/2;
        	CGFloat result = (isCelsius) ? celTemp : celTemp * 9/5 + 32;
        	NSLog(@"result: %f", result);
        	NSLog(@"celTemp * 9/5 + 32: %f", celTemp * 9/5 + 32);
        	[keys addObject:@(result)];
        }
        else {
        	HourlyForecast* hour = daysOrHours[i];
        	BOOL isCelsius = [[FreyrPreferences sharedInstance] isCelsius];
        	CGFloat celTemp = [hour.detail floatValue];
        	CGFloat result = (isCelsius) ? celTemp : celTemp * 9/5 + 32;
        	NSLog(@"result: %f", result);
        	NSLog(@"celTemp * 9/5 + 32: %f", celTemp * 9/5 + 32);
        	[keys addObject:@(result)];
        }
    }

    [self setDayForecasts:[NSArray arrayWithArray:keys]];
}
-(NSArray*)getForecastForNumberOfDays:(int)days {
	int count = _dayForecasts.count;

	if (days > count) days = count;

	return [_dayForecasts subarrayWithRange:NSMakeRange(0, days)];
}
-(void)setDayForecasts:(NSArray*)dayForecasts {
	_dayForecasts = dayForecasts;
}
@end