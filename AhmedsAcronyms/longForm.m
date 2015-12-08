//
//  longForm.m
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import "longForm.h"

@implementation longForm

- (instancetype)initWithJSONDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self)
    {
        self.name = json[@"lf"];
        self.usedSince = [json[@"since"]integerValue];
        self.usageFreq =[json[@"freq"]integerValue];
    }
    return self;
}

@end
