#import "Interfaces.h"
#import "FreyrController.h"
#import "FreyrForecast.h"
#import "FreyrPreferences.h"

%group Memes

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    WeatherPreferences* prefs = [%c(WeatherPreferences) sharedPreferences];
    City* city = [prefs localWeatherCity];

    //check if they don't have location services enabled
    if (!city) {
        NSLog(@"User did not have location services enabled for Weather.app");
        [[[UIAlertView alloc] initWithTitle:@"Freyr" message:@"Please ensure you have location services enabled for the Weather app to use Freyr.\nYou can enable location services in Settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        return;
    }

    [city update];

    [[FreyrForecast sharedInstance] calculateForecast];
}
%end

%hook SBIconView
%new
-(void)setAssociatedGesture:(id)object {
     objc_setAssociatedObject(self, @selector(associatedGesture), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
-(id)associatedGesture {
    return objc_getAssociatedObject(self, @selector(associatedGesture));
}
%end

%hook SBFolderController
-(BOOL)pushFolder:(id)arg1 animated:(BOOL)arg2 completion:(void(^)(void))arg3 {
    NSLog(@"pushFolder");

    //remove it before they see it if it was already there
    [[FreyrController sharedInstance] removeForecastViewFromPerformingIcon];
    [[FreyrController sharedInstance] dismissFreyr];

    //custom completion block
    void (^cust)(void) = ^void(void){
        arg3();

        [[FreyrController sharedInstance] setupPerformingIcon];
    };

    return %orig(arg1, arg2, cust);
}
-(void)unscatterAnimated:(BOOL)arg1 afterDelay:(double)arg2 withCompletion:(void(^)(void))arg3 {
    //%log;

    //remove it before they see it if it was already there
    [[FreyrController sharedInstance] removeForecastViewFromPerformingIcon];
    [[FreyrController sharedInstance] dismissFreyr];

    //custom completion block
    void (^cust)(void) = ^void(void){
        arg3();

        [[FreyrController sharedInstance] setupPerformingIcon];
    };

    %orig(arg1, arg2, cust);
}
%end

%hook SBIconController
-(void)setIsEditing:(BOOL)editing {
    %log;
    %orig;

    SBIconView* weatherIcon = [[FreyrController sharedInstance] retreivePerformingIcon];
    [[FreyrController sharedInstance] dismissFreyr];
    if (!weatherIcon) {
        NSLog(@"Icon could not be retreived.");
        return;
    }
    NSLog(@"weatherIcon: %@", weatherIcon);

    if (editing) {
        [weatherIcon removeGestureRecognizer:[weatherIcon associatedGesture]];

        [[FreyrController sharedInstance] removeForecastViewFromPerformingIcon];
    }
    else {
        if (![weatherIcon associatedGesture]) {
            NSLog(@"Associated gesture did not exist. Creating.");
            UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:[FreyrController sharedInstance] action:@selector(handlePan:)];
            [weatherIcon setAssociatedGesture:panRec];
        }

        if ([[weatherIcon gestureRecognizers] containsObject:[weatherIcon associatedGesture]]) {
            NSLog(@"weatherIcon contained gesture, removing it.");
            [weatherIcon removeGestureRecognizer:[weatherIcon associatedGesture]];
        }

        [weatherIcon addGestureRecognizer:[weatherIcon associatedGesture]];

        [[FreyrController sharedInstance] addForecastViewToPerformingIcon];
    }
}
%end

/*
%hook SBLockScreenManager
-(void) _finishUIUnlockFromSource:(int)source withOptions:(id)options {
    //remove it before they see it if it was already there
    [[FreyrController sharedInstance] removeForecastViewFromPerformingIcon];

    %orig;
} 

-(void)_sendUILockStateChangedNotification {
    //remove it before they see it if it was already there
    [[FreyrController sharedInstance] removeForecastViewFromPerformingIcon];

    %orig;
}
-(void)_deviceLockedChanged:(id)arg1 {
    //remove it before they see it if it was already there
    [[FreyrController sharedInstance] removeForecastViewFromPerformingIcon];

    [[FreyrController sharedInstance] setupPerformingIcon];

    %orig;
}

%end
*/
%end

%ctor {
    if ([[FreyrPreferences sharedInstance] isEnabled]) %init(Memes);

    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        dlopen("System/Library/PrivateFrameworks/Weather.framework/Weather", RTLD_NOW);
    }
}