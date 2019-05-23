//
//  UIImageViewTap.h
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <react-native-fast-image/FFFastImageView.h>


@protocol MWTapDetectingFastImageViewDelegate;

@interface MWTapDetectingFastImageView : UIImageView {}

@property (nonatomic, weak) id <MWTapDetectingFastImageViewDelegate> tapDelegate;

@end

@protocol MWTapDetectingFastImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end
