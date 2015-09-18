//
//  PrimeNumbersGenerator.m
//  Generator
//
//  Created by Milana Koronkevich on 9/17/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "PrimeNumbersGenerator.h"

NSString *const Limit = @"limit";
NSString *const Primes = @"primes";

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

- (NSArray *)generatePrimeNumbers:(NSUInteger)userLimit {
    NSArray *finalPrimesArray = [NSArray array];
    NSNumber *cacheLimit = [self.cache objectForKey:Limit] ? [self.cache objectForKey:Limit] : [NSNumber numberWithInt:0];
    NSArray *primesCacheArray = [self.cache objectForKey:Primes];
    
    if(cacheLimit &&
       primesCacheArray && [primesCacheArray count] > 0 &&
       userLimit > [cacheLimit integerValue]) {
        
        finalPrimesArray = [self generatePrimesWithUserLimit:userLimit
                                                  cacheLimit:[cacheLimit integerValue]
                                            primesCacheArray:primesCacheArray];
        [self.cache setObject:finalPrimesArray forKey:Primes];
        [self.cache setObject:[NSNumber numberWithInteger:userLimit] forKey:Limit cost:100];
    } else if(cacheLimit &&
              primesCacheArray && [primesCacheArray count] > 0 &&
              userLimit <= [cacheLimit integerValue]) {
        
        finalPrimesArray = [self generatePrimesWithUserLimit:userLimit
                                            primesCacheArray:primesCacheArray];
    } else {
        
        finalPrimesArray = [self generatePrimesWithEmptyCache:userLimit];
        [self.cache setObject:finalPrimesArray forKey:Primes];
        [self.cache setObject:[NSNumber numberWithInteger:userLimit] forKey:Limit cost:100];
    }
    
    return finalPrimesArray;
}

- (NSArray *)generatePrimesWithEmptyCache:(NSUInteger)userLimit {
    NSMutableArray *finalPrimesArray = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < userLimit; i++) {
        array[i] = [NSNull null];
    }
    
    for(int i = 2; i < userLimit; i++) {
        if ([array[i] isKindOfClass:[NSNull class]]) {
            [finalPrimesArray addObject:[NSNumber numberWithInt:i]];
            for (int j = i * i; j < userLimit; j += i)
                array[j] = [NSNumber numberWithInt:i];
        }
    }
    
    return [finalPrimesArray copy];
}

- (NSArray *)generatePrimesWithUserLimit:(NSUInteger)userLimit primesCacheArray:(NSArray *)primesCacheArray {
    NSMutableArray *finalPrimesArray = [NSMutableArray array];
    for(NSNumber *number in primesCacheArray) {
        if([number integerValue] < userLimit) {
            [finalPrimesArray addObject:number];
        }
    }
    
    return [finalPrimesArray copy];
}

- (NSArray *)generatePrimesWithUserLimit:(NSUInteger)userLimit cacheLimit:(NSUInteger)cacheLimit primesCacheArray:(NSArray *)primesCacheArray {
    NSMutableArray *finalPrimesArray = [NSMutableArray array];
    NSMutableArray *sieveArray = [NSMutableArray array];
    NSMutableArray *primesSqrtArray = [NSMutableArray array];
    
    for(int i = 0; i < userLimit - cacheLimit ; i++) {
        sieveArray[i] = [NSNumber numberWithBool:true];
    }
    
    for(NSNumber *num in primesCacheArray) {
        if([num integerValue] < sqrt(userLimit) ) {
            [primesSqrtArray addObject:num ];
        }
    }
    
    for(int i = 0; i < primesSqrtArray.count; i++) {
        NSInteger h  = cacheLimit % [primesSqrtArray[i] integerValue];
        NSInteger j = h == 0 ? 0 : [primesSqrtArray[i] integerValue] - h;
        for(; j < userLimit - cacheLimit ; j += [primesSqrtArray[i] integerValue]) {
            sieveArray[j] = [NSNumber numberWithBool:false];
        }
    }
    
    for(int i = cacheLimit ; i < sqrt(userLimit) ; i++) {
        if(sieveArray[i - cacheLimit]) {
            for(int j = i * i; j < userLimit - cacheLimit ; j += i) {
                sieveArray[j - cacheLimit] = [NSNumber numberWithBool:false];
            }
        }
    }
    
    [finalPrimesArray addObjectsFromArray:primesCacheArray];
    for(int i = 0; i < [sieveArray count]; i++) {
        if([sieveArray[i] integerValue] == 1) {
            [finalPrimesArray addObject:[NSNumber numberWithInt:i + (int)cacheLimit]];
        }
    }
    
    return [finalPrimesArray copy];
}

@end
