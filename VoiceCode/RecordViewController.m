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

#import "NSError+Description.h"

@interface RecordViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (strong, nonatomic) IBOutlet RecorderView *recorderView;

@property (strong, nonatomic) AVAudioRecorder *voiceRecorder;
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Path to file
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"voice-record.m4a", nil];
    NSURL *recordingPathURL = [NSURL fileURLWithPathComponents:pathComponents];
    NSLog(@"%@", recordingPathURL.absoluteString);
    
    // Session and recorder
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        [error description];
    } else {
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
        
        NSError *error = nil;
        self.voiceRecorder = [[AVAudioRecorder alloc] initWithURL:recordingPathURL settings:recordSetting error:&error];
        if (error) {
            [error description];
        }
        self.voiceRecorder.delegate = self;
        self.voiceRecorder.meteringEnabled = YES;
    }
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
    if (self.voicePlayer.playing) {
        [self.voicePlayer pause];
    }
    
    if (self.voiceRecorder.recording) {
        [self.voiceRecorder pause];
        [self.recorderView setRecordButtonTitle:@"Record"];
    } else {
        [self.voiceRecorder record];
        [self.recorderView setRecordButtonTitle:@"Pause"];
    }
}

- (IBAction)stopButtonTapped:(id)sender {
    [self.voiceRecorder stop];
    
    AVAudioSession *voiceAudio = [AVAudioSession sharedInstance];
    [voiceAudio setActive:NO error:nil];
    
    [self.recorderView setRecordButtonTitle:@"Record"];
}
- (IBAction)playButtonTapped:(id)sender {
    if (!self.voiceRecorder.recording) {
        self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.voiceRecorder.url error:nil];
        self.voicePlayer.delegate = self;
        [self.voicePlayer play];
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
