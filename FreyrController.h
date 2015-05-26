#import "Interfaces.h"

@interface FreyrController : NSObject {
	CGPoint _panCoord;
	CGRect _originalRootFrame;
	CGRect _originalDockFrame;
	NSMutableArray* _verticalAdjacentBelowIcons;
}
@property (nonatomic, retain) SBIconView* performingIcon;
@property (nonatomic, retain) UIView* forecastView;
+(instancetype)sharedInstance;
+(NSArray*)currentOrderedForecast;
+(UIColor*)textColorForBlurStyle:(NSInteger)style;
-(UIView*)viewForCurrentForecast;
-(SBIconView*)retreivePerformingIcon;
-(void)setupPerformingIcon;
-(void)addForecastViewToPerformingIcon;
-(void)removeForecastViewFromPerformingIcon;
-(void)dismissFreyr;
-(void)fullyOpenFreyr;
@end