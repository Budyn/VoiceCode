//
//  RecorderView.h
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <EZAudio/EZAudio.h>
#import <UIKit/UIKit.h>

@interface RecorderView : UIView
@property (weak, nonatomic) IBOutlet EZAudioPlot *freqView;
@property (weak, nonatomic) IBOutlet EZAudioPlot *timeView;

- (void)setRecordButtonTitle:(NSString *)title;
- (void)setStopButtonStatus:(BOOL)selected;
- (void)setDelegateForTextField:(id)delegate;
- (void)setRecordingInfo:(NSDictionary *)info;
- (void)clearRecordingInfo;

- (void)startSpinningAnimation;
- (void)stopSpinningAnimation;

- (void)enableRecording;
- (void)enableInfo;
- (void)enableCharts;

@end
