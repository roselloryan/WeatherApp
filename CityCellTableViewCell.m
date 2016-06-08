//
//  CityCellTableViewCell.m
//  Weather App


#import "CityCellTableViewCell.h"


@implementation CityCellTableViewCell


-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        // build and add blurEffect to tableViewCells
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];

        visualEffectView.frame = self.bounds;
        visualEffectView.layer.cornerRadius = 5.0f;
        visualEffectView.layer.masksToBounds = YES;
        [self addSubview:visualEffectView];
        [self sendSubviewToBack:visualEffectView];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.3f;
        self.layer.borderColor = [[UIColor orangeColor]colorWithAlphaComponent:0.5].CGColor;
        
        // build selected backgroundView
        UIView *selectedView = [UIView new];
        selectedView.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = selectedView;
    }
    
    return self;
}


-(void)layoutSubviews {
    
    // fixes visualEffectView not filling cell and delete button appearance. 
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass: [UIVisualEffectView class]]) {
        subview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        }
    };
}

@end
