//
//  ViewController.m
//  Generator
//
//  Created by Milana Koronkevich on 9/16/15.
//  Copyright (c) 2015 Milana Koronkevich. All rights reserved.
//

#import "ViewController.h"
#import "UILabel+FontSize.h"
#import "UITextField+FontSize.h"
#import "PrimeNumbersGenerator.h"
#import "DeviceSize.h"
#import "Generation.h"

#define ACCEPTABLE_CHARECTERS @"0123456789"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *generateButton;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *primeNumbersArray;
@property (nonatomic) NSInteger limit;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.generateButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [self.generateButton.titleLabel adjustFont];
    self.generateButton.enabled = NO;
    [self.generateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.limitTextField.font = [UIFont systemFontOfSize:14.0];
    [self.limitTextField adjustFont];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldChanged)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.limitTextField];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)textFieldChanged {
    self.generateButton.enabled = self.limitTextField.text.length != 0 ? YES : NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) && IS_IPHONE) {
        self.topViewConstraint.constant = 32.0;
    }
}

- (BOOL)decimalCharacters:(NSString *)string {
    NSCharacterSet *charecterSet = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    NSString *filteredString = [[string componentsSeparatedByCharactersInSet:charecterSet] componentsJoinedByString:@""];
    
    return [string isEqualToString:filteredString];
}

- (BOOL)decimalCharactersLength:(NSString *)string textField:(UITextField *)textField range:(NSRange)range {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 7;
}

#pragma mark - Core Data

- (void)insertNewObject:(NSUInteger)limit {
    Generation *generation = [NSEntityDescription insertNewObjectForEntityForName:@"Generation" inManagedObjectContext:_managedObjectContext];
    generation.limit = [NSNumber numberWithInteger:limit];
    generation.date = [NSDate date];
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    [fetch setEntity:[NSEntityDescription entityForName:@"Generation" inManagedObjectContext:_managedObjectContext]];
    
    NSError *error = nil;
    
    if(![_managedObjectContext save:&error]) {
        NSLog(@"Save Error: %@", [error localizedDescription]);
    }
}


#pragma mark - Text Field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self decimalCharacters:string] && [self decimalCharactersLength:string textField:textField range:range];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.limitTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - Table view delegate and data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.primeNumbersArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height * 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self.primeNumbersArray[indexPath.row] stringValue];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    [cell.textLabel adjustFont];
    
    return cell;
}

#pragma mark - IBAction

- (IBAction)generateAction:(id)sender {
    self.limit = [self.limitTextField.text integerValue];
    self.limitTextField.text = @"";
    [self textFieldChanged];
    
    //[self insertNewObject:self.limit];
    
    self.primeNumbersArray = [NSArray new];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.spinner];
    
    __weak ViewController *blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.spinner startAnimating];
        });
        
        blockSelf.primeNumbersArray = [[PrimeNumbersGenerator sharedInstance] generatePrimeNumbers:blockSelf.limit];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [blockSelf.spinner stopAnimating];
            [blockSelf.tableView reloadData];
        });
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"HistorySegue"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
}

@end
