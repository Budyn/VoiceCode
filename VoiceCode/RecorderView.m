//
//  RecorderView.m
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import "RecorderView.h"
@interface RecorderView()
@property (weak, nonatomic) IBOutlet UIView *voiceRecordingControlView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation RecorderView
- (void)awakeFromNib {
    [super awakeFromNib];
    
    // View
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    
    self.voiceRecordingControlView.clipsToBounds = YES;
    self.voiceRecordingControlView.layer.cornerRadius = 10;
}

- (void)setRecordButtonTitle:(NSString *)title {
    [self.recordButton setTitle:title forState:UIControlStateNormal];
}

- (void)setStopButtonTitle:(NSString *)title {
    [self.stopButton setTitle:title forState:UIControlStateNormal];
}

- (void)setPlayButtonTitle:(NSString *)title {
    [self.playButton setTitle:title forState:UIControlStateNormal];
}

@end
