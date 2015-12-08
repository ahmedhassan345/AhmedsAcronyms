//
//  acronym.m
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import "acronym.h"

@implementation acronym

- (instancetype)initWithJSONDictionary:(NSDictionary*)json
{
    self = [super init];
    if (self)
    {
        self.name = json[@"sf"];
        if ([json[@"lfs"] isKindOfClass:[NSArray class]])
        {
            NSMutableArray* lfsMutArr = [NSMutableArray array];
            for (NSDictionary* dict in json[@"lfs"])
            {
                longForm* lf = [[longForm alloc]initWithJSONDictionary:dict];
                [lfsMutArr addObject:lf];
            }
            self.longForms = [NSArray arrayWithArray:lfsMutArr];
        }
        if ([self.longForms count]) self.mostUsedLF = [[self.longForms valueForKeyPath:@"@max.usageFreq"] integerValue];
    }
    return self;
}

@end
