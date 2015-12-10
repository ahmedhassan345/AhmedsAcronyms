//
//  AcromineAPIWorker.m
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import "AcromineAPIWorker.h"
#import "AFNetworking.h"
#import "acronym.h"

@implementation AcromineAPIWorker

+ (AcromineAPIWorker*)sharedWorker
{
    static AcromineAPIWorker *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance) return sharedInstance;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[AcromineAPIWorker alloc] init];
    });
    
    return sharedInstance;
}

- (void)getLongFormsForAcronym:(NSString*)acr WithResponseHandler:(AcronymResponseHandler)responseHandler
{
    if (!acr)
    {
        responseHandler(nil,NSLocalizedString(@"Acronym is required.", @""));
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [manager GET:@"http://www.nactem.ac.uk/software/acromine/dictionary.py" parameters:@{@"sf":acr} success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSMutableArray* retrievedAcronyms = [NSMutableArray array];
        for (NSDictionary* dict in responseObject)
        {
            acronym* anAcronym = [[acronym alloc]initWithJSONDictionary:dict];
            [retrievedAcronyms addObject:anAcronym];
        }
        responseHandler(retrievedAcronyms,nil);
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        responseHandler(nil,[error localizedDescription]);
    }];
}

@end
