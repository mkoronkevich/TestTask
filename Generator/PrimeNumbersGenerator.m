//
//  PrimeNumbersGenerator.m
//  Generator
//
//  Created by Milana Koronkevich on 9/17/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "PrimeNumbersGenerator.h"

@interface PrimeNumbersGenerator ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation PrimeNumbersGenerator

+ (instancetype)sharedInstance {
    static PrimeNumbersGenerator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PrimeNumbersGenerator alloc] init];
        sharedInstance.cache = [[NSCache alloc] init];
    });
    return sharedInstance;
}

- (NSArray *)generatePrimeNumbers:(NSUInteger)limit {
    NSMutableArray *primeNumbersArray = [NSMutableArray array];
    NSArray *cacheArray = [self.cache objectForKey:[NSNumber numberWithInteger:limit]];

    if(cacheArray) {
        primeNumbersArray = [cacheArray mutableCopy];
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for(int i = 0; i < limit; i++) {
            array[i] = [NSNull null];
        }
        
        for(int i = 2; i < limit; i++) {
            if ([array[i] isKindOfClass:[NSNull class]]) {
                [primeNumbersArray addObject:[NSNumber numberWithInt:i]];
                for (int j=i*i; j < limit; j+=i)
                    array[j] = [NSNumber numberWithInt:i];
            }
        }
        [self.cache setObject:primeNumbersArray forKey:[NSNumber numberWithInteger:limit]];
    }
    
    return [primeNumbersArray copy];
}

@end
