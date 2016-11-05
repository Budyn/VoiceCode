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
- (void)setStopButtonStatus:(BOOL)selected;
- (void)setDelegateForTextField:(id)delegate;
- (void)setRecordingInfo:(NSDictionary *)info;
- (void)clearRecordingInfo;

- (void)startSpinningAnimation;
- (void)stopSpinningAnimation;

- (void)enableRecording;
- (void)enableInfo;


@end
