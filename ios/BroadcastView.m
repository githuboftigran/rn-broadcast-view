//
//  BroadcastView.m
//  RNBroadcastView
//
//  Created by Tigran Sahakyan on 1/10/19.
//  Copyright © 2019 Tigran Sahakyan. All rights reserved.
//

#import "BroadcastView.h"

CGFloat const LINE_WIDTH_RELATIVE_TO_PARENT = 0.1;
NSString* const STATION_COLOR = @"#4286f4";
NSString* const WAVE_COLOR = @"#ff60ad";
NSTimeInterval const WAVE_TIME = 3;
NSTimeInterval const WAVE_DIFF = WAVE_TIME / 4;

@implementation BroadcastView

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

BOOL _broadcasting;
UIColor* __waveColor;
UIColor* __stationColor;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        __stationColor = [BroadcastView colorWithHexString:(STATION_COLOR)];
        __waveColor = [BroadcastView colorWithHexString:(WAVE_COLOR)];
        [self setTimeQueue:[[NSMutableArray<NSDate *> alloc]init]];
        [self setWavingTimer:[[NSTimer alloc] init]];
        _broadcasting = false;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setStationColor:(NSString *)color {
    __stationColor = [BroadcastView colorWithHexString:(color)];
}

- (void)setWaveColor:(NSString *)color {
    __waveColor = [BroadcastView colorWithHexString:(color)];
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
