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
#import "RSA.h"

#import "NSError+Description.h"

static vDSP_Length const FFTWindowSize = 4096;
static NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI2bvVLVYrb4B0raZgFP60VXY\ncvRmk9q56QiTmEm9HXlSPq1zyhyPQHGti5FokYJMzNcKm0bwL1q6ioJuD4EFI56D\na+70XdRz1CjQPQE3yXrXXVvOsmq9LsdxTFWsVBTehdCmrapKZVVx6PKl7myh0cfX\nQmyveT/eqyZK1gYjvQIDAQAB\n-----END PUBLIC KEY-----";
static NSString *privkey = @"-----BEGIN PRIVATE KEY-----\nMIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMMjZu9UtVitvgHS\ntpmAU/rRVdhy9GaT2rnpCJOYSb0deVI+rXPKHI9Aca2LkWiRgkzM1wqbRvAvWrqK\ngm4PgQUjnoNr7vRd1HPUKNA9ATfJetddW86yar0ux3FMVaxUFN6F0KatqkplVXHo\n8qXubKHRx9dCbK95P96rJkrWBiO9AgMBAAECgYBO1UKEdYg9pxMX0XSLVtiWf3Na\n2jX6Ksk2Sfp5BhDkIcAdhcy09nXLOZGzNqsrv30QYcCOPGTQK5FPwx0mMYVBRAdo\nOLYp7NzxW/File//169O3ZFpkZ7MF0I2oQcNGTpMCUpaY6xMmxqN22INgi8SHp3w\nVU+2bRMLDXEc/MOmAQJBAP+Sv6JdkrY+7WGuQN5O5PjsB15lOGcr4vcfz4vAQ/uy\nEGYZh6IO2Eu0lW6sw2x6uRg0c6hMiFEJcO89qlH/B10CQQDDdtGrzXWVG457vA27\nkpduDpM6BQWTX6wYV9zRlcYYMFHwAQkE0BTvIYde2il6DKGyzokgI6zQyhgtRJ1x\nL6fhAkB9NvvW4/uWeLw7CHHVuVersZBmqjb5LWJU62v3L2rfbT1lmIqAVr+YT9CK\n2fAhPPtkpYYo5d4/vd1sCY1iAQ4tAkEAm2yPrJzjMn2G/ry57rzRzKGqUChOFrGs\nlm7HF6CQtAs4HC+2jC0peDyg97th37rLmPLB9txnPl50ewpkZuwOAQJBAM/eJnFw\nF5QAcL4CYDbfBKocx82VX/pFXng50T7FODiWbbL4UnxICE0UBFInNNiWJxNEb6jL\n5xd0pcy9O2DOeso=\n-----END PRIVATE KEY-----";


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

- (IBAction)encryptButtonAction:(id)sender {
    NSData *recordedData = [NSData dataWithContentsOfURL:self.recorder.voiceRecorder.url];
    NSData *encryptedData = [RSA encryptData:recordedData publicKey:pubkey];
    NSData *decryptedData = [RSA decryptData:encryptedData publicKey:pubkey];
    NSError *error;
    
    self.recorder.voicePlayer = [[AVAudioPlayer alloc] initWithData:decryptedData error:&error];
    
    if (!self.recorder.voiceRecorder.recording) {
        [self.recorder.voicePlayer play];
    }
    
    //self.recorder.voicePlayer = [[AVAudioPlayer alloc] initWithData:decryptedData error:&error];
    //[self.recorder.voicePlayer play];
    
    //NSData *data = [RSA encryptData: publicKey:pubkey];
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

@end
