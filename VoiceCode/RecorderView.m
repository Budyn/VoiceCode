//
//  RecorderView.m
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>
#import "RecorderView.h"

static NSString * const kFileNameKey = @"FileNameKey";
static NSString * const kRecordingDuration = @"FileDurationKey";
static NSString * const kFileFormat = @"FileFormatKey";

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
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *secondaryOverlayView;

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
    
    [self.stopButton setEnabled:NO];
    
}

- (void)setRecordButtonTitle:(NSString *)title {
    [self.recordButton setTitle:title forState:UIControlStateNormal];
}

- (void)setStopButtonStatus:(BOOL)selected {
    [self.stopButton setEnabled:selected];
}

- (void)setDelegateForTextField:(id)delegate {
    if ([delegate conformsToProtocol:@protocol(UITextFieldDelegate)]) {
        self.fileNameTextField.delegate = delegate;
    }
}

- (void)startSpinningAnimation {
    [self.spinner startAnimating];
}

- (void)stopSpinningAnimation {
    [self.spinner stopAnimating];
}

- (void)enableRecording {
    [UIView animateWithDuration:1
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.overlayView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.overlayView.hidden = NO;
                     }
     ];
}

- (void)enableInfo {
    [UIView animateWithDuration:1
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.secondaryOverlayView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         self.secondaryOverlayView.hidden = NO;
                     }
     ];
}

- (void)setRecordingInfo:(NSDictionary *)info {
    self.nameLabel.text = [info objectForKey:kFileNameKey];
    self.durationLabel.text = [(NSNumber *)[info objectForKey:kRecordingDuration] stringValue];
    self.formatLabel.text = [info objectForKey:kFileFormat];
    self.sampleRateLabel.text = [(NSNumber *)[info objectForKey:AVSampleRateKey] stringValue];
    self.channelsLabel.text = [(NSNumber *)[info objectForKey:AVNumberOfChannelsKey] stringValue];
}

- (void)clearRecordingInfo {
    self.nameLabel.text = @"";
    self.durationLabel.text = @"";
    self.formatLabel.text = @"";
    self.sampleRateLabel.text = @"";
    self.channelsLabel.text = @"";
}

@end
