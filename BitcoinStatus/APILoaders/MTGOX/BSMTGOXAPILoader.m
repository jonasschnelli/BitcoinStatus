//
//  BSMTGOXLoader.m
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BSMTGOXAPILoader.h"

@implementation BSMTGOXAPILoader

+ (void)startLoadValueWithCurrency:(NSString *)currency {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://data.mtgox.com/api/2/BTC%@/money/ticker", currency]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if(error || data == nil) {
                                   [[NSNotificationCenter defaultCenter] postNotificationName:BSNewDataFromRemoteNotification object:nil];
                               }
                               @try {
                                   NSString *jsonResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@", jsonResponse);
                                   
                                   NSError *jsonError = nil;
                                   id object = [NSJSONSerialization
                                                JSONObjectWithData:data
                                                options:0
                                                error:&jsonError];
                                   
                                   if(jsonError) {
                                       [[NSNotificationCenter defaultCenter] postNotificationName:BSNewDataFromRemoteNotification object:nil];
                                   }
                                   else {
                                       // parse the right value
                                       NSNumber *num = [[[(NSDictionary *)object objectForKey:@"data"] objectForKey:@"last"] objectForKey:@"value"];
                                       
                                       BSDataFromRemote *dataFromRemote = [[BSDataFromRemote alloc] init];
                                       dataFromRemote.tradeValue = num;
                                       
                                       [[NSNotificationCenter defaultCenter] postNotificationName:BSNewDataFromRemoteNotification object:dataFromRemote];
                                   }
                               }
                               @catch (NSException *exception) {
                                   [[NSNotificationCenter defaultCenter] postNotificationName:BSNewDataFromRemoteNotification object:nil];
                               }
                               @finally {
                                   
                               }
                               
                           }
     
     ];
}

@end
