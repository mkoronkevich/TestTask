//
//  HistoryTableViewController.h
//  Generator
//
//  Created by Milana Koronkevich on 9/18/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface HistoryTableViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
