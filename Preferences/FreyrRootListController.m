#include "FreyrRootListController.h"
#import <Preferences/PSDiscreteSlider.h>

static NSInteger specIndex;
static PSSpecifier *sliderSpecifier;

@implementation FreyrRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		specIndex = [_specifiers indexOfObject:[self specifierForID:@"SliderLabelCell"]];
		sliderSpecifier = [self specifierForID:@"ForecastCountCell"];
		int value = [[self readPreferenceValue:sliderSpecifier] intValue] ?: 4;
		sliderLabel = [PSSpecifier groupSpecifierWithHeader:@"Number of forecasts" footer:[NSString stringWithFormat:@"We'll show %d forecast%@", value, ((value == 1) ? @"" : @"s")]];
		_specifiers[specIndex] = sliderLabel;
	}

	return _specifiers;
}

-(void)sliderMoved:(PSDiscreteSlider *)slider {

	sliderLabel = [PSSpecifier groupSpecifierWithHeader:@"Number of forecasts" footer:[NSString stringWithFormat:@"We'll show %d forecast%@", (int)slider.value, ((slider.value == 1) ? @"" : @"s")]];
	_specifiers[specIndex] = sliderLabel;
	[self setPreferenceValue:@(slider.value) specifier:sliderSpecifier];
	[self reloadSpecifierAtIndex:specIndex];
	//[self reloadSpecifierAtIndex:specIndex+1];

}

-(void)openTwitter:(PSSpecifier *)specifier {
    NSString *screenName = [specifier.properties[@"handle"] substringFromIndex:1]; //remove the "@"
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", screenName]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@", screenName]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tweetings:///user?screen_name=%@", screenName]]];
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", screenName]]];
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://mobile.twitter.com/%@", screenName]]];
}

-(void)openReddit:(PSSpecifier *)specifier {
    NSString *screenName = specifier.properties[@"handle"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://www.reddit.com" stringByAppendingPathComponent:screenName]]];
}

@end
