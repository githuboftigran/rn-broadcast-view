//
//  BroadcastView.h
//  RNBroadcastView
//
//  Created by Tigran Sahakyan on 1/10/19.
//  Copyright © 2019 Tigran Sahakyan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BroadcastView : UIControl

@property NSString *stationColor;
@property NSString *waveColor;
@property NSMutableArray<NSDate *>* timeQueue;
@property NSTimer *wavingTimer;
@property (nonatomic) BOOL broadcasting;

@end

NS_ASSUME_NONNULL_END
