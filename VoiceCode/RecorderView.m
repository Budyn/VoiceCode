//
//  RecorderView.m
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import "RecorderView.h"

@interface RecorderView()
@property (weak, nonatomic) IBOutlet UIView *voiceRecordingControlView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *progressContainerView;
@property (weak, nonatomic) IBOutlet UIView *recordingInformationView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UILabel *sampleRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelsLabel;

@property (strong, nonatomic) MMMaterialDesignSpinner *spinner;

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
    
    self.spinner = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    self.spinner.lineWidth = 1.0f;
    self.spinner.tintColor = [UIColor redColor];
    [self.progressContainerView addSubview:self.spinner];
    
    self.recordingInformationView.clipsToBounds = YES;
    self.recordingInformationView.layer.cornerRadius = 10;
    
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

- (void)startSpinningAnimation {
    [self.spinner startAnimating];
}

- (void)stopSpinningAnimation {
    [self.spinner stopAnimating];
}

@end
