#import "FreyrDiscreteSliderTableCell.h"
#import <objc/runtime.h>
#import <Preferences/PSSpecifier.h>

@implementation FreyrDiscreteSliderTableCell

-(id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(id)arg2 specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:arg1 reuseIdentifier:arg2 specifier:specifier];
    if (self) {
        PSDiscreteSlider *slider = [[objc_getClass("PSDiscreteSlider") alloc] initWithFrame:CGRectZero];
        
        [slider addTarget:specifier.target action:@selector(sliderMoved:) forControlEvents:UIControlEventAllTouchEvents];
        [self setControl:slider];
   		
    }
    return self;
}

@end