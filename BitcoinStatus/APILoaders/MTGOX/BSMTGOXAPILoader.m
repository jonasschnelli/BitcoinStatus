//
//  BSMTGOXLoader.m
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BSMTGOXAPILoader.h"

@implementation BSMTGOXAPILoader

+ (void)startLoadValueWithCurrency:(BSCurrency)currency {
    NSURL *url = [NSURL URLWithString:@"https://data.mtgox.com/api/2/BTCUSD/money/ticker"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSString *jsonResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"%@", jsonResponse);
                               
                               NSError *jsonError = nil;
                               id object = [NSJSONSerialization
                                            JSONObjectWithData:data
                                            options:0
                                            error:&jsonError];
                               NSLog(@"%@", object);
                               
                               // parse the right value
                               NSNumber *num = [[[(NSDictionary *)object objectForKey:@"data"] objectForKey:@"avg"] objectForKey:@"value"];
                               
                               BSDataFromRemote *dataFromRemote = [[BSDataFromRemote alloc] init];
                               dataFromRemote.tradeValue = num;
                               
                               [[NSNotificationCenter defaultCenter] postNotificationName:BSNewDataFromRemoteNotification object:dataFromRemote];
                           }
     
     ];
}

@end
