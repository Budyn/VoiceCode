//
//  NSError+Description.m
//  VoiceCode
//
//  Created by Daniel Budynski on 04/11/2016.
//  Copyright © 2016 Budyn&Friends. All rights reserved.
//

#import "NSError+Description.h"

@implementation NSError(Description)
- (void)fullDescription {
    NSLog(@"Domain: %@", self.domain);
    NSLog(@"Error Code: %ld", (long)self.code);
    NSLog(@"Description: %@", [self localizedDescription]);
    NSLog(@"Reason: %@", [self localizedFailureReason]);
}

@end
