#import "FreyrController.h"
#import "FreyrForecast.h"
#import <objc/runtime.h>
#import "FreyrPreferences.h"

#define kAnimationDuration 0.15

@implementation FreyrController 
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
		SBDockIconListView* dockListView = [[objc_getClass("SBIconController") sharedInstance] dockListView];
		_originalDockFrame = ((SBDockView*)[dockListView superview]).frame;
		_originalRootFrame = [[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame;
	}
	return self;
}
+(NSArray*)currentOrderedForecast {
	//TODO allow variable number of days
	return [[FreyrForecast sharedInstance] getForecastForNumberOfDays:[[FreyrPreferences sharedInstance] numberOfForecasts]];
}
+(UIColor*)textColorForBlurStyle:(NSInteger)style {
	if (style == 2010) return [UIColor darkGrayColor];
	return [UIColor whiteColor];
}
-(UIView*)viewForCurrentForecast {
	CALL_ORIGIN;

	CGRect pFrame = _performingIcon.frame;
	UIView* holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pFrame.size.width, pFrame.size.height*3)];
	//holderView.backgroundColor = [UIColor redColor];

	//add blur view
	_UIBackdropView* backgroundView = [[_UIBackdropView alloc] initWithFrame:holderView.frame autosizesToFitSuperview:YES settings:[_UIBackdropViewSettings settingsForPrivateStyle:[[FreyrPreferences sharedInstance] blurStyle]]];
	//backgroundView.layer = _performingIcon.layer;
	backgroundView.layer.cornerRadius = 15;
	backgroundView.layer.masksToBounds = YES;
	[holderView insertSubview:backgroundView atIndex:0];

	//get current forcast
	NSArray* currentForecast = [FreyrController currentOrderedForecast];
	NSLog(@"currentForecast: %@", currentForecast);

	CGFloat origin = _performingIcon.frame.size.width;
	for (NSNumber* averageTemp in currentForecast) {
		UILabel* tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, origin, pFrame.size.width, (holderView.frame.size.height - _performingIcon.frame.size.width)/currentForecast.count)];
		tempLabel.textAlignment = NSTextAlignmentCenter;
		tempLabel.textColor = [FreyrController textColorForBlurStyle:[[FreyrPreferences sharedInstance] blurStyle]];
		tempLabel.numberOfLines = 0;
		//tempLabel.lineBreakMode = UILineBreakModeWordWrap;
		tempLabel.text = [NSString stringWithFormat:@"%iº", [averageTemp intValue]];

		[holderView addSubview:tempLabel];

		NSLog(@"Label: %@", tempLabel);

		origin += tempLabel.frame.size.height;
	}

	holderView.tag = kForecastViewTag;

	return holderView;
}

-(void)calculateBelow2Icons {
	CALL_ORIGIN;

	//get vertically adjacent icons below it
	if (!_verticalAdjacentBelowIcons) {
		_verticalAdjacentBelowIcons = [[NSMutableArray alloc] init];
	}

	[_verticalAdjacentBelowIcons removeAllObjects];

	NSArray* apps = [[[objc_getClass("SBIconController") sharedInstance] currentFolderIconList] visibleIcons];
	if (!apps) apps = [[[objc_getClass("SBIconController") sharedInstance] currentRootIconList] visibleIcons];

	NSLog(@"apps: %@", apps);

	int wIndex = [apps indexOfObject:[(SBIconModel*)[[objc_getClass("SBIconController") sharedInstance] model] expectedIconForDisplayIdentifier:@"com.apple.weather"]];
	int col = [objc_getClass("SBIconListView") iconColumnsForInterfaceOrientation:[[UIDevice currentDevice] orientation]];

	//check if there exists an app 4 below this one
	if ((apps.count-1 > wIndex + col)) {
		SBIcon* below1 = [apps objectAtIndex:wIndex + col];
		NSLog(@"below1: %@", below1);
		SBIconView* iconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:below1];
		if (!iconView) return;
		[_verticalAdjacentBelowIcons addObject:iconView];

		if ((apps.count-1 > wIndex + col*2)) {
			SBIcon* below2 = [apps objectAtIndex:wIndex + col*2];
			NSLog(@"below2: %@", below2);
			SBIconView* iconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:below2];
			if (!iconView) return;
			[_verticalAdjacentBelowIcons addObject:iconView];
		}
	}
}
-(SBIconView*)retreivePerformingIcon {
	CALL_ORIGIN;

	SBIconController *controller = [objc_getClass("SBIconController") sharedInstance];
	SBIcon *iconForOpeningApp = [controller.model expectedIconForDisplayIdentifier:@"com.apple.weather"];

	SBIconViewMap *iconMap = [objc_getClass("SBIconViewMap") homescreenMap];
	SBIconView *weatherIcon = [iconMap mappedIconViewForIcon:iconForOpeningApp];

	NSLog(@"controller: %@", controller);
	NSLog(@"iconForOpeningApp: %@", iconForOpeningApp);
	NSLog(@"iconMap: %@", iconMap);
	NSLog(@"weatherIcon: %@", weatherIcon);

	_performingIcon = weatherIcon;

	return weatherIcon;
}
-(void)setupPerformingIcon {
	CALL_ORIGIN;

	//add the forecast view to the icon
	SBIconView* weatherIcon = [self retreivePerformingIcon];

	[self addForecastViewToPerformingIcon];

	if (![weatherIcon associatedGesture]) {
        UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:[FreyrController sharedInstance] action:@selector(handlePan:)];
        [weatherIcon setAssociatedGesture:panRec];
    }

	[weatherIcon addGestureRecognizer:[weatherIcon associatedGesture]];
}
-(void)addForecastViewToPerformingIcon {
	CALL_ORIGIN;

	if (!_performingIcon) {
		NSLog(@"Performing icon did not exist");
		[self retreivePerformingIcon];
	}

	[self removeForecastViewFromPerformingIcon];

	[[FreyrForecast sharedInstance] calculateForecast];
	[self calculateBelow2Icons];

	//add it behind the icon
	_forecastView = [self viewForCurrentForecast];
	_forecastView.clipsToBounds = YES;
	_forecastView.frame = CGRectMake(_performingIcon.frame.origin.x, _performingIcon.frame.origin.y, _performingIcon.frame.size.width, _performingIcon.frame.size.width);
	NSLog(@"_forecastView: %@", _forecastView);
	NSLog(@"_performingIcon: %@", _performingIcon);
	NSLog(@"[_performingIcon superview}: %@", [_performingIcon superview]);
	if (![_performingIcon superview]) return;
	[[_performingIcon superview] insertSubview:_forecastView belowSubview:_performingIcon];
}
-(void)removeForecastViewFromPerformingIcon {
	while (UIView* view = [[_performingIcon superview] viewWithTag:kForecastViewTag]) {
		[view removeFromSuperview];
	}
}
-(void)handlePan:(UIPanGestureRecognizer *)pan {
	if (pan.state == UIGestureRecognizerStateBegan) {
		[self calculateBelow2Icons];

		_panCoord = [pan locationInView:_forecastView];

		[UIView animateWithDuration:0.25 animations:^{
			_performingIcon.iconLabelAlpha = 0.0;
		}];        
	}

	CGPoint newCoord = [pan locationInView:_forecastView];
	CGFloat dY = (newCoord.y-_panCoord.y) / 4;

	CGFloat adjustedHeight = _forecastView.frame.size.height + dY;

	if (adjustedHeight > (_performingIcon.frame.size.height*3)) {
		adjustedHeight = _performingIcon.frame.size.height*3;
	}
	if (adjustedHeight < _performingIcon.frame.size.width) {
		adjustedHeight = _performingIcon.frame.size.width;
	}

	_forecastView.frame = CGRectMake(_performingIcon.frame.origin.x, _performingIcon.frame.origin.y, _performingIcon.frame.size.width, adjustedHeight);

	//if it goes off the bottom of the screen and it's in the dock, move the dock and screen up
	if ([_performingIcon isInDock]) {
		NSLog(@"_performingIcon was in dock");
		//make sure no icons fade out
		[_verticalAdjacentBelowIcons removeAllObjects];
		SBDockIconListView* dockListView = [[objc_getClass("SBIconController") sharedInstance] dockListView];
		SBDockView* dockView = (SBDockView*)[dockListView superview];

		NSLog(@"dockView: %@", dockView);

		//move the dock and the main icons up
		if (_forecastView.frame.origin.y + _forecastView.frame.size.height > (_originalDockFrame.size.height)) {
			//move the dock and the main icons up
			SBRootIconListView* rootIconList = [[objc_getClass("SBIconController") sharedInstance] currentRootIconList];
			CGRect frame = rootIconList.frame;
			CGRect dockFrame = dockView.frame;

			NSLog(@"dockFrame: %@", NSStringFromCGRect(dockFrame));

			dockView.frame = CGRectMake(dockFrame.origin.x, dockFrame.origin.y - ((_forecastView.frame.size.height + (_forecastView.frame.origin.y * 2)) - dockFrame.size.height), dockFrame.size.width, dockFrame.size.height + ((_forecastView.frame.size.height + (_forecastView.frame.origin.y * 2)) - dockFrame.size.height));
			NSLog(@"dockView.frame.size.height: %f", dockView.frame.size.height);
			NSLog(@"_originalDockFrame.size.height: %f", _originalDockFrame.size.height);
			NSLog(@"(dockView.frame.size.height - _originalDockFrame.size.height): %f", (dockView.frame.size.height - _originalDockFrame.size.height));
			rootIconList.frame = CGRectMake(frame.origin.x, _originalRootFrame.origin.y - (dockView.frame.size.height - _originalDockFrame.size.height), frame.size.width, frame.size.height);

			NSLog(@"dockFrame: %@", NSStringFromCGRect(dockView.frame));
		}
		//else NSLog(@"forecastView was not too big for the dock");
	}
	//if it goes off the bottom of the screen, move the screen up
	else if (_forecastView.frame.origin.y + _forecastView.frame.size.height > ([[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame.origin.y + [[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame.size.height)) {
		CGRect frame = [[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame;
		[[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame = CGRectMake(frame.origin.x, -((_forecastView.frame.origin.y + _forecastView.frame.size.height) - (frame.size.height)), frame.size.width, frame.size.height);
	}

	//fade apps below weather if necessary
	for (SBIconView* view in _verticalAdjacentBelowIcons) {
		if (_performingIcon.frame.origin.y + adjustedHeight > view.frame.origin.y) {
			[UIView animateWithDuration:kAnimationDuration animations:^{
				view.alpha = 0.0;
			}];
		}
		else {
			[UIView animateWithDuration:kAnimationDuration animations:^{
				view.alpha = 1.0;
			}];
		}
	}

	if (pan.state == UIGestureRecognizerStateEnded) {
		[self handleUntouchFromHeight:adjustedHeight];
	}
}
-(void)handleUntouchFromHeight:(CGFloat)height {
	//if they've opened more than halfway down the 3-app total distance
	if (height > (_performingIcon.frame.size.height + _performingIcon.frame.size.height*1.5)) {
		//Fully open
		[self fullyOpenFreyr];
	}
	else {
		//Close back up
		[self dismissFreyr];
	}
}
-(void)dismissFreyr {
	[UIView animateWithDuration:kAnimationDuration animations:^{
		CGRect frame = [[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame;
		//TODO find out if there is a scenario in which the y origin will not be 0
		[[objc_getClass("SBIconController") sharedInstance] currentRootIconList].frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height);

		//change the dock back to its original frame
		SBDockIconListView* dockListView = [[objc_getClass("SBIconController") sharedInstance] dockListView];
		SBDockView* dockView = (SBDockView*)[dockListView superview];
		dockView.frame = _originalDockFrame;

		_forecastView.frame = CGRectMake(_performingIcon.frame.origin.x, _performingIcon.frame.origin.y, _performingIcon.frame.size.width, _performingIcon.frame.size.width);
				
		_performingIcon.iconLabelAlpha = 1.0;

		for (SBIconView* view in _verticalAdjacentBelowIcons) {
			view.alpha = 1.0;
		}
	}];
}
-(void)fullyOpenFreyr {
	[UIView animateWithDuration:kAnimationDuration animations:^{
		_forecastView.frame = CGRectMake(_performingIcon.frame.origin.x, _performingIcon.frame.origin.y, _performingIcon.frame.size.width, _performingIcon.frame.size.height * 3);

		_performingIcon.iconLabelAlpha = 0.0;

		for (SBIconView* view in _verticalAdjacentBelowIcons) {
			view.alpha = 0.0;
		}
	}];
}
@end
