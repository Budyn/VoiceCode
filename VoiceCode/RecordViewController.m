//
//  RecordViewController.m
//  VoiceCode
//
//  Created by Daniel Budynski on 02/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <EZAudio/EZAudio.h>
#import <AVFoundation/AVFoundation.h>
#import "RecordViewController.h"
#import "RecorderView.h"
#import "Recorder.h"

#import "NSError+Description.h"

static vDSP_Length const FFTWindowSize = 4096;

@interface RecordViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, EZMicrophoneDelegate, EZAudioFFTDelegate>
@property (strong, nonatomic) IBOutlet RecorderView *recorderView;
@property (strong, nonatomic) Recorder *recorder;

@property (nonatomic,strong) EZMicrophone *microphone;
@property (nonatomic, strong) EZAudioFFTRolling *fft;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self)weakSelf = self;
    [self.recorderView setDelegateForTextField:weakSelf];
    
    self.recorderView.timeView.plotType = EZPlotTypeBuffer;
    self.recorderView.freqView.shouldFill = YES;
    self.recorderView.freqView.plotType = EZPlotTypeBuffer;
    self.recorderView.freqView.shouldCenterYAxis = YES;

    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                           delegate:self];
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
        [self.microphone startFetchingAudio];
        
        [self.recorderView setRecordButtonTitle:@"Pause"];
        [self.recorderView enableCharts];
        [self.recorderView startSpinningAnimation];
    }
    
    [self.recorderView setStopButtonStatus:YES];
    [self.recorderView clearRecordingInfo];
}

- (IBAction)stopButtonTapped:(id)sender {
    [self.recorder.voiceRecorder stop];
    [self.recorderView stopSpinningAnimation];
    
    AVAudioSession *voiceAudio = [AVAudioSession sharedInstance];
    [voiceAudio setActive:NO error:nil];
    
    NSError *error = nil;
    self.recorder.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.voiceRecorder.url error:&error];
    if (error) {
        [error fullDescription];
    }
    self.recorder.voicePlayer.delegate = self;
    
    [self.recorder addFileDurationToSettings];
    [self.recorderView setRecordingInfo:[self.recorder getRecordingSettings]];
    [self.recorderView enableInfo];
    [self.recorderView setRecordButtonTitle:@"Record"];
}
- (IBAction)playButtonTapped:(id)sender {
    if (!self.recorder.voiceRecorder.recording) {
        [self.recorder.voicePlayer play];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.text) {
        self.recorder = [[Recorder alloc] initWithFormat:kAudioFormatMPEG4AAC sampleRate:16000 channelNumber:2 fileName:textField.text];
        self.recorder.voiceRecorder.delegate = self;
        return YES;
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.recorderView enableRecording];
    textField.enabled = NO;
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Finish!" message:@"Player has finished" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - EZMicrophoneDelegate
-(void)    microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    //
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recorderView.timeView updateBuffer:buffer[0]
                              withBufferSize:bufferSize];
    });
}

#pragma mark - EZAudioFFTDelegate
- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recorderView.freqView updateBuffer:fftData withBufferSize:(UInt32)bufferSize];
    });
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
