//
//  BroadcastView.m
//  RNBroadcastView
//
//  Created by Tigran Sahakyan on 1/10/19.
//  Copyright © 2019 Tigran Sahakyan. All rights reserved.
//

#import "BroadcastView.h"
#import "UIUtils.m"

CGFloat const LINE_WIDTH_RELATIVE_TO_PARENT = 0.1;
NSString* const STATION_COLOR = @"#4286f4";
NSString* const WAVE_COLOR = @"#ff60ad";
NSTimeInterval const WAVE_TIME = 3;
NSTimeInterval const WAVE_DIFF = WAVE_TIME / 4;

@implementation BroadcastView

BOOL _broadcasting;
UIColor* __waveColor;
UIColor* __stationColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __stationColor = [UIUtils colorWithHexString:(STATION_COLOR)];
        __waveColor = [UIUtils colorWithHexString:(WAVE_COLOR)];
        [self setTimeQueue:[[NSMutableArray<NSDate *> alloc]init]];
        [self setWavingTimer:[[NSTimer alloc] init]];
        _broadcasting = false;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setStationColor:(NSString *)color {
    __stationColor = [UIUtils colorWithHexString:(color)];
}

- (void)setWaveColor:(NSString *)color {
    __waveColor = [UIUtils colorWithHexString:(color)];
}

- (void)setBroadcasting:(BOOL)broadcasting {
    [self handleBroadcasting:broadcasting];
    _broadcasting = broadcasting;
}

- (void)handleBroadcasting:(BOOL)broadcasting {
    if (broadcasting == _broadcasting) {
        return;
    }
    
    if (!broadcasting) {
        [[self wavingTimer] invalidate];
        [self setNeedsDisplay];
        return;
    }
    
    NSTimeInterval postDelay = 0;
    NSDate* now = [[NSDate alloc] init];
    BOOL isFirst = [[self timeQueue] count] == 0;
    if (!isFirst) {
        NSDate* lastQueued = [[self timeQueue] lastObject];
        if ([lastQueued timeIntervalSinceDate:now] > 0) {
            return;
        }
        
        NSTimeInterval diff = [now timeIntervalSinceDate:lastQueued];
        if (diff < WAVE_DIFF) {
            postDelay = WAVE_DIFF - diff;
        }
    }
    
    [self scheduleNext:postDelay];
}

- (void)scheduleNext:(NSTimeInterval) interval {
    [self setWavingTimer:[NSTimer scheduledTimerWithTimeInterval:interval repeats:false block:^(NSTimer* timer){
        [[self timeQueue] addObject:[[NSDate alloc] init]];
        [self setNeedsDisplay];
        [self scheduleNext:WAVE_DIFF];
    }]];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat cx = [self bounds].size.width / 2;
    CGFloat cy = [self bounds].size.height / 2;
    
    CGFloat r = cx < cy ? cx : cy;
    CGFloat transmitterRadius = r / 8;
    CGFloat stationWidth = r * LINE_WIDTH_RELATIVE_TO_PARENT;
    [__stationColor setFill];
    [__stationColor setStroke];
    CGContextMoveToPoint(context, cx - r / 4, cy + r - stationWidth);
    CGContextAddLineToPoint(context, cx, cy);
    CGContextMoveToPoint(context, cx + r / 4, cy + r - stationWidth);
    CGContextAddLineToPoint(context, cx, cy);
    CGContextMoveToPoint(context, cx - r / 4, cy + r - stationWidth);
    CGContextAddLineToPoint(context, cx + r / 8, cy + r / 2);
    CGContextMoveToPoint(context, cx + r / 4, cy + r - stationWidth);
    CGContextAddLineToPoint(context, cx - r / 8, cy + r / 2);
    
    CGContextSetLineWidth(context, stationWidth);
    CGContextStrokePath(context);
    
    if (_broadcasting) {
        [__waveColor setFill];
    }
    
    CGContextAddArc(context, cx, cy, transmitterRadius, 0, 2 * M_PI, true);
    CGContextFillPath(context);
    [__waveColor setStroke];
    
    NSDate* now = [[NSDate alloc] init];
    
    NSMutableArray* removedItems = [NSMutableArray array];
    for (id time in [self timeQueue]) {
        NSTimeInterval diff = [now timeIntervalSinceDate:time];
        if (diff >= WAVE_TIME) {
            [removedItems addObject:time];
        } else {
            CGFloat fraction = diff / WAVE_TIME;
            CGFloat startRadius = transmitterRadius - stationWidth / 2;
            
            CGContextAddArc(context, cx, cy, startRadius + (r - startRadius) * fraction, 0, 2 * M_PI, true);
            CGContextSetLineWidth(context, stationWidth * (1 - fraction) * (1 - fraction));
            CGContextStrokePath(context);
        }
    }
    
    [[self timeQueue] removeObjectsInArray:removedItems];
    if ([[self timeQueue] count] > 0) {
        [NSTimer scheduledTimerWithTimeInterval: 1.0 / 60 repeats:false block:^(NSTimer* timer) {
            [self setNeedsDisplay];
        }];
    }
}

@end
