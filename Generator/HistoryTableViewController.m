//
//  HistoryTableViewController.m
//  Generator
//
//  Created by Milana Koronkevich on 9/18/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "UILabel+FontSize.h"
#import "UITextView+FontSize.h"
#import "Generation.h"
#import "HistoryTableViewCell.h"
#import "PrimeNumbersGenerator.h"

@interface HistoryTableViewController ()

@property (nonatomic) BOOL isLoadMaxLimit;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                initWithTitle:@""
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:nil];
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationItem.title = @"HISTORY";
    
    self.isLoadMaxLimit = NO;

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    [self.view addSubview:self.spinner];
    
    __weak HistoryTableViewController *blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.spinner startAnimating];
        });
        
        NSInteger maxLimit = [self maxLimitInGenegartions];
        if(maxLimit != 0) {
            [[PrimeNumbersGenerator sharedInstance] generatePrimeNumbersForHistory:maxLimit];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [blockSelf.spinner stopAnimating];
            blockSelf.isLoadMaxLimit = YES;
            [blockSelf.tableView reloadData];
        });
    });

}

#pragma mark - Table View 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return self.isLoadMaxLimit ? [sectionInfo numberOfObjects] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height * 0.2167;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HistoryTableViewCell";
    HistoryTableViewCell *cell = (HistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(HistoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.limitLabel.text = [NSString stringWithFormat:@"TIME: %@         LIMIT: %@", [self currentDate:[object valueForKey:@"date"]], [object valueForKey:@"limit"]];
    cell.limitLabel.font = [UIFont systemFontOfSize:10.0];
    [cell.limitLabel adjustFont];
    cell.primesTextView.text = [NSString stringWithFormat:@"[ %@ ]", [[[PrimeNumbersGenerator sharedInstance] generatePrimeNumbersForHistory:[[object valueForKey:@"limit"] integerValue]] componentsJoinedByString:@", "]];
    cell.primesTextView.editable = NO;
    cell.primesTextView.font = [UIFont systemFontOfSize:11.0];
    [cell.primesTextView adjustFont];
    [cell.primesTextView scrollRangeToVisible:NSMakeRange(0, 1)];
}

- (NSString *)currentDate:(NSDate *)date {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

//#pragma mark - Core Data

- (NSInteger)maxLimitInGenegartions {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Generation"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest
                                                                   error:&error];
    
    NSMutableArray *generationArray = [NSMutableArray arrayWithArray:fetchedObjects];
    
    [generationArray sortUsingDescriptors:[NSArray arrayWithObjects:
                                       [NSSortDescriptor sortDescriptorWithKey:@"limit" ascending:YES], nil]];
    
    return [generationArray count] != 0 ? [[generationArray[0] limit] integerValue] : 0 ;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Generation"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self.fetchedResultsController setDelegate:self];

    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(HistoryTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
