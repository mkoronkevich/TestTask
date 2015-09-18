//
//  HistoryTableViewController.m
//  Generator
//
//  Created by Milana Koronkevich on 9/18/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "UILabel+FontSize.h"
#import "Generation.h"

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSArray *generationsArray;

@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"HistoryTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:nil];
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;

    self.generationsArray = [self generations];
}

#pragma mark - Table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.generationsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height * 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryTableViewCell"
                                                            forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Generation *generation = (Generation *)self.generationsArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"TIME: %@         LIMIT: %@", [generation date], [generation limit]];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:10.0];
    [cell.textLabel adjustFont];
    
    return cell;
}

#pragma mark - Core Data

- (NSMutableArray *)generations {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Generation"
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *generationArray = [NSMutableArray arrayWithArray:fetchedObjects];
    
    [generationArray sortUsingDescriptors:[NSArray arrayWithObjects:
                                       [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES], nil]];
    return generationArray;
}

@end
