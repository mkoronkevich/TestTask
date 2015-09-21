//
//  ViewController.h
//  Generator
//
//  Created by Milana Koronkevich on 9/16/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;

@end

