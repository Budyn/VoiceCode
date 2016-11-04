//
//  RecordViewController.m
//  VoiceCode
//
//  Created by Daniel Budynski on 02/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RecordViewController.h"
#import "RecorderView.h"
#import "Recorder.h"

#import "NSError+Description.h"

@interface RecordViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (strong, nonatomic) IBOutlet RecorderView *recorderView;
@property (strong, nonatomic) Recorder *recorder;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recorder = [[Recorder alloc] initWithFormat:kAudioFormatMPEG4AAC sampleRate:10000 channelNumber:2 fileName:@"file.m4a"];
    self.recorder.voiceRecorder.delegate = self;
    self.recorder.voicePlayer.delegate = self;
    self.recorder.voicePlayer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Setter & Getter
- (RecorderView *)recorderView {
    return (RecorderView *)self.view;
}

#pragma mark Button Actions
- (IBAction)recordButtonTapped:(id)sender {
    if (self.recorder.voicePlayer.playing) {
        [self.recorder.voicePlayer pause];
        [self.recorderView stopSpinningAnimation];
    }
    
    if (self.recorder.voiceRecorder.recording) {
        [self.recorder.voiceRecorder pause];
        [self.recorderView setRecordButtonTitle:@"Record"];
        [self.recorderView stopSpinningAnimation];
    } else {
        [self.recorder.voiceRecorder record];
        [self.recorderView setRecordButtonTitle:@"Pause"];
        [self.recorderView startSpinningAnimation];
    }
}

- (IBAction)stopButtonTapped:(id)sender {
    [self.recorder.voiceRecorder stop];
    [self.recorderView stopSpinningAnimation];
    
    AVAudioSession *voiceAudio = [AVAudioSession sharedInstance];
    [voiceAudio setActive:NO error:nil];
    
    [self.recorderView setRecordButtonTitle:@"Record"];
}
- (IBAction)playButtonTapped:(id)sender {
    if (!self.recorder.voiceRecorder.recording) {
        [self.recorder.voicePlayer play];
    }
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Finish!" message:@"Player has finished" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
