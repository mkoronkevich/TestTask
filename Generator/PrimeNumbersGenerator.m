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
NSInteger const Block = 100;

@interface PrimeNumbersGenerator ()

@property (strong, nonatomic) NSCache *cache;
@property (strong, nonatomic) NSCache *historyCache;

@end

@implementation PrimeNumbersGenerator

+ (instancetype)sharedInstance {
    static PrimeNumbersGenerator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PrimeNumbersGenerator alloc] init];
        sharedInstance.cache = [[NSCache alloc] init];
        sharedInstance.historyCache = [[NSCache alloc] init];
    });
    return sharedInstance;
}

- (NSArray *)generatePrimeNumbers:(NSInteger)userLimit {
    return [self generatePrimeNumbers:userLimit cache:self.cache];
}

- (NSArray *)generatePrimeNumbersForHistory:(NSInteger)userLimit {
    return [self generatePrimeNumbers:userLimit cache:self.historyCache];
}

- (NSArray *)generatePrimeNumbers:(NSInteger)userLimit cache:(NSCache *)cache {
    NSArray *finalPrimesArray = [NSArray array];
    NSNumber *cacheLimit = [cache objectForKey:Limit] ? [cache objectForKey:Limit] : [NSNumber numberWithInt:0];
    NSArray *primesCacheArray = [cache objectForKey:Primes];
    
    if(userLimit <= [cacheLimit integerValue]) {
        
        finalPrimesArray = [self generatePrimesWithUserLimit:userLimit
                                            primesCacheArray:primesCacheArray];
    } else {
        finalPrimesArray = [self generatePrimesWithCache:[cacheLimit integerValue]
                                        primesCacheArray:primesCacheArray
                                                   block:Block
                                               userLimit:userLimit];
        [cache setObject:finalPrimesArray forKey:Primes];
        [cache setObject:[NSNumber numberWithInteger:userLimit] forKey:Limit];
    }
    
    return finalPrimesArray;
}

- (NSArray *)generatePrimesWithUserLimit:(NSInteger)userLimit primesCacheArray:(NSArray *)primesCacheArray {
    NSMutableArray *finalPrimesArray = [NSMutableArray array];
    for(NSNumber *number in primesCacheArray) {
        if([number integerValue] < userLimit) {
            [finalPrimesArray addObject:number];
        }
    }
    
    return [finalPrimesArray copy];
}

- (NSArray *)generatePrimesWithCache:(NSInteger)cacheLimit primesCacheArray:(NSArray *)primesCacheArray block:(NSInteger)block userLimit:(NSInteger)userLimit {
    NSMutableArray *newCache = [NSMutableArray array];
    int n = (int)userLimit / block + 1;
    NSMutableArray *sieveArray = [NSMutableArray array];
    for(int i = 0; i < userLimit ; i++) {
        sieveArray[i] = [NSNumber numberWithBool:true];
    }
    
    for (int igl = 0; igl < n; igl++) {
        NSMutableArray *prime = [NSMutableArray array];
        for(int i = 0; i < primesCacheArray.count; i++) {
            if([primesCacheArray[i] integerValue] >= igl * block && [primesCacheArray[i] integerValue] < (igl + 1) * block) {
                [prime addObject:primesCacheArray[i]];
            }
        }
        
        if((igl + 1) * block > cacheLimit) {
            for(int i = 0; i < prime.count; i++) {
                NSInteger h = (igl * block) % [prime[i] integerValue];
                NSInteger j = h == 0 ? igl * block : i - h + igl * block;
                for (; j < (igl + 1) * block && j < userLimit; j += [prime[i] integerValue]) {
                    sieveArray[j] = [NSNumber numberWithBool:false];
                }
            }
            for (int i = (int)MAX( MAX(igl * block, cacheLimit), 2); i < (igl + 1) * block && i < userLimit; i++) {
                if([sieveArray[i] integerValue] == 1) {
                    [prime addObject:[NSNumber numberWithInt:i]];
                    for (int j = i + i; j < (igl + 1) * block && j < userLimit; j += i) {
                        sieveArray[j] = [NSNumber numberWithBool:false];
                    }
                }
            }
        }
        
        int count = (int)ABS(userLimit - MAX(cacheLimit, (igl + 1) * block)) / block + 1;
        
        dispatch_apply(count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(size_t jgl){
            int start = n - count + (int)jgl;
            for(int i = 0; i < prime.count; i++) {
                NSInteger h = (start * block) % [prime[i] integerValue];
                NSInteger j = h == 0 ? start * block : [prime[i] integerValue] - h + start * block;
                for (; j < (start + 1) * block && j < userLimit; j += [prime[i] integerValue]) {
                    sieveArray[j] = [NSNumber numberWithBool:false];
                }
            }
        });
        
        [newCache addObjectsFromArray:prime];
    }
    
    return newCache;
}

@end
