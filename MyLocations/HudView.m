//
//  HubView.m
//  MyLocations
//
//  Created by zhu yongxuan on 15/8/18.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "HudView.h"

@implementation HudView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated
{
    HudView *hubView = [[HudView alloc] initWithFrame:view.bounds];
    
    hubView.opaque = NO;
    
    [view addSubview:hubView];
    view.userInteractionEnabled = NO;
    
    [hubView showAnimated:animated];
    return hubView;
}

- (void)showAnimated:(BOOL)animated
{
    if (animated) {
        
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0f;
            self.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)drawRect:(CGRect)rect
{
    const CGFloat boxWidth = 96.0f;
    const CGFloat boxHeight = 96.0f;
    
    CGRect boxRect = CGRectMake(roundf(self.bounds.size.width - boxWidth) / 2.0f, roundf(self.bounds.size.height - boxHeight) / 2.0f, 96.0f, 96.0f);
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f]; // 制作圆角
    
    [[UIColor colorWithWhite:0.3f alpha:0.8f] setFill];
    [roundedRect fill];
    
    UIImage *image = [UIImage imageNamed:@"Checkmark"];
    
    CGPoint imagePoint = CGPointMake(self.center.x - roundf(image.size.width / 2.0f), self.center.y - roundf(image.size.height / 2.0f) - boxHeight / 8.0f);
    
    [image drawAtPoint:imagePoint];
    
    NSDictionary *attributes = @{NSFontAttributeName :[UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    CGSize textSize = [self.text sizeWithAttributes:attributes];
    CGPoint textPoint = CGPointMake(self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 4.0f);
    
    [self.text drawAtPoint:textPoint withAttributes:attributes];
}



@end
