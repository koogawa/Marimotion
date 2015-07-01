//
//  InterfaceController.m
//  Marimotion WatchKit Extension
//
//  Created by koogawa on 2015/06/18.
//  Copyright © 2015年 Kosuke Ogawa. All rights reserved.
//

#import "InterfaceController.h"
#import <CoreMotion/CoreMotion.h>

static const CGFloat kMarimoWidth   = 40.0;
static const CGFloat kMarimoHeight  = 40.0;
static const CGFloat kMaxWidth      = 156.0 - kMarimoWidth; // 42mm only
static const CGFloat kMaxHeight     = 175.0 - kMarimoHeight; // 42mm only

@interface InterfaceController()

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *tankGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *marimoImage;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (assign, nonatomic) CGPoint marimoPoint;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    self.motionManager = [[CMMotionManager alloc] init];
    self.marimoPoint = CGPointMake(kMaxWidth/2, 0); // center
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];

    // 初期位置
    [self showMarimoAtPoint:self.marimoPoint];

    if (self.motionManager.accelerometerAvailable)
    {
        // センサーの更新間隔の指定
        self.motionManager.accelerometerUpdateInterval = 1 / 10;  // 10Hz

        // ハンドラを指定
        CMAccelerometerHandler handler = ^(CMAccelerometerData *data, NSError *error)
        {
            // 現在の位置を取得
            CGFloat x = self.marimoPoint.x;
            CGFloat y = self.marimoPoint.y;

            // 位置を更新
            x -= data.acceleration.x;
            y += data.acceleration.y;

            // 衝突判定
            x = (x < 0) ? 0 : x; // left
            x = (x > kMaxWidth) ? kMaxWidth : x; // right
            y = (y < 0) ? 0 : y; // top
            y = (y > kMaxHeight) ? kMaxHeight : y; // bottom

            // 位置をセット
            self.marimoPoint = CGPointMake(x, y);

            // 画面に表示
            [self showMarimoAtPoint:self.marimoPoint];
        };

        // 加速度の取得開始
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];

    if (self.motionManager.accelerometerActive) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

- (void)showMarimoAtPoint:(CGPoint)point {
    [self.tankGroup setContentInset:UIEdgeInsetsMake(point.y, point.x, 0, 0)];
}

@end



