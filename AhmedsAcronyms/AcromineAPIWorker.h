//
//  AcromineAPIWorker.h
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AcronymResponseHandler)(NSArray* acronyms, NSString *errorString);

@interface AcromineAPIWorker : NSObject

+ (AcromineAPIWorker*)sharedWorker;

- (void)getLongFormsForAcronym:(NSString*)acr WithResponseHandler:(AcronymResponseHandler)responseHandler;

@end
