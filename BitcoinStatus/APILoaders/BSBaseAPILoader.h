//
//  BSBaseLoader.h
//  BitcoinStatus
//
//  Created by Jonas Schnelli on 03.04.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSDataFromRemote.h"

typedef enum BSCurrency {
    BSCurrencyUSD,
    BSCurrencyEUR,
    BSCurrencyCHF
} BSCurrency;

@interface BSBaseAPILoader : NSObject

+ (void)startLoadValueWithCurrency:(BSCurrency)currency;

@end
