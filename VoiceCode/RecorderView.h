//
//  RecorderView.h
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecorderView : UIView
- (void)setRecordButtonTitle:(NSString *)title;
- (void)startSpinningAnimation;
- (void)stopSpinningAnimation;

@end
