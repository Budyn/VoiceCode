//
//  Recorder.h
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Recorder : NSObject
@property (strong, nonatomic) AVAudioRecorder *voiceRecorder;
@property (strong, nonatomic) AVAudioPlayer *voicePlayer;

- (instancetype)initWithFormat:(NSInteger)audioFormat sampleRate:(float)sampleRate channelNumber:(NSInteger)channelNumber fileName:(NSString *)fileNAme NS_DESIGNATED_INITIALIZER;
@end
