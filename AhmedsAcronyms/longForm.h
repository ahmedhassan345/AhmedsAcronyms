//
//  longForm.h
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface longForm : NSObject

- (instancetype)initWithJSONDictionary:(NSDictionary*)json;

@property NSString* name;
@property NSInteger usageFreq;
@property NSInteger usedSince;

@end
