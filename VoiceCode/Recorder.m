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
@property (strong, nonatomic) NSURL *recordingPathURL;
@end

@implementation Recorder
- (instancetype)initWithFormat:(NSInteger)audioFormat
                    sampleRate:(float)sampleRate
                 channelNumber:(NSInteger)channelNumber
                      fileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        // RECORDER
        if (audioFormat == (NSInteger)kAudioFormatMPEG4AAC) {
            fileName = [fileName stringByAppendingString:@".m4a"];
        }
        
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *pathComponents = [NSArray arrayWithObjects: documentsDirectoryPath, fileName, nil];
        NSURL *recordingPathURL = [NSURL fileURLWithPathComponents:pathComponents];
        self.recordingPathURL = recordingPathURL;
        _recordingSettings = @{ AVFormatIDKey : [NSNumber numberWithInt:(int)audioFormat],
                                AVSampleRateKey : [NSNumber numberWithFloat:(float)sampleRate],
                                AVNumberOfChannelsKey : [NSNumber numberWithInt:(int)channelNumber],
                                kFileNameKey : fileName,
                                kFileFormat : [recordingPathURL pathExtension]};
        
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
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFormat:kAudioFormatMPEG4AAC sampleRate:441000 channelNumber:2 fileName:@"default.m4a"];
    return self;
}

- (void)addFileDurationToSettings {
    if (self.voicePlayer) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        NSTimeInterval time = self.voicePlayer.duration;
        [tempDict addEntriesFromDictionary:self.recordingSettings];
        [tempDict setObject:[NSNumber numberWithFloat:time] forKey:kRecordingDuration];
        self.recordingSettings = tempDict;
    }
}

- (NSDictionary *)getRecordingSettings {
    return self.recordingSettings;
}

@end
