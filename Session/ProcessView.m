//
//  ProcessView.m
//  Session
//
//  Created by Mr.Q on 16/6/15.
//  Copyright © 2016年 QLS. All rights reserved.
//

#import "ProcessView.h"

@implementation ProcessView


- (void)setProcess:(float)process{
    _process = process;

    [self setTitle:[NSString stringWithFormat:@"%0.2f%%",process * 100] forState:UIControlStateNormal];

    [self  setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGFloat margin  = 5;
    UIBezierPath *path = [UIBezierPath bezierPath];

    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);

    CGFloat radius = MIN(center.x, center.y) - margin;

    CGFloat startAngle = - M_PI_2;
    CGFloat endAngle = 2*M_PI_2 * self.process + startAngle;

    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];

    path.lineWidth = margin;
    path.lineCapStyle = kCGLineCapRound;

    [[UIColor orangeColor]setStroke];

    [path stroke];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitle:@"0.00%" forState:UIControlStateNormal];
    }
    return self;
}

@end
