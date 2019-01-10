//
//  BroadcastViewManager.m
//  RNBroadcastView
//
//  Created by Tigran Sahakyan on 1/10/19.
//  Copyright © 2019 Tigran Sahakyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BroadcastView.h"
#import <React/RCTViewManager.h>

@interface BroadcastViewManager : RCTViewManager

@end

@implementation BroadcastViewManager

RCT_EXPORT_MODULE()

- (UIView *) view
{
    return [[BroadcastView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(broadcasting, BOOL)
RCT_EXPORT_VIEW_PROPERTY(stationColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(waveColor, NSString)

@end
