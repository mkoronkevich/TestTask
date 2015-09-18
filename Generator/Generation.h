//
//  Generation.h
//  Generator
//
//  Created by Milana Koronkevich on 9/18/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Generation : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * limit;

@end
