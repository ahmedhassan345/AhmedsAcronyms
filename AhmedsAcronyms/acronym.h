//
//  acronym.h
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "longForm.h"

@interface acronym : NSObject

- (instancetype)initWithJSONDictionary:(NSDictionary*)json;

@property NSString* name;
@property NSArray* longForms;
@property NSInteger mostUsedLF;

@end
