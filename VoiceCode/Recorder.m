//
//  Recorder.m
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import "Recorder.h"
#import "NSError+Description.h"

@interface Recorder()
@property (strong, nonatomic) NSDictionary *recordingSettings;
@property (strong, nonatomic) AVAudioSession *session;

@end

@implementation Recorder
- (instancetype)initWithFormat:(NSInteger)audioFormat
                    sampleRate:(float)sampleRate
                 channelNumber:(NSInteger)channelNumber
                      fileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        // RECORDER
        _recordingSettings = @{ AVFormatIDKey : [NSNumber numberWithInt:(int)audioFormat],
                                AVSampleRateKey : [NSNumber numberWithFloat:sampleRate],
                                AVNumberOfChannelsKey : [NSNumber numberWithInt:(int)channelNumber] };
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *pathComponents = [NSArray arrayWithObjects: documentsDirectoryPath, fileName, nil];
        NSURL *recordingPathURL = [NSURL fileURLWithPathComponents:pathComponents];

        NSLog(@"%@", recordingPathURL.absoluteString);
        
        self.session = [AVAudioSession sharedInstance];
        NSError * __autoreleasing error = nil;
        [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error) {
            [error fullDescription];
        } else {
            error = nil;
            self.voiceRecorder = [[AVAudioRecorder alloc] initWithURL:recordingPathURL settings:self.recordingSettings error:&error];
            if (error) {
                [error fullDescription];
            } else {
                self.voiceRecorder.meteringEnabled = YES;
            }
        }
        
        // PLAYER
        error = nil;
        self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.voiceRecorder.url error:&error];
        if (error) {
            [error fullDescription];
        }
        
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFormat:kAudioFormatMPEG4AAC sampleRate:441000 channelNumber:2 fileName:@"default.m4a"];
    return self;
}

@end
