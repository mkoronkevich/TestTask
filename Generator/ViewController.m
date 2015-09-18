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

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *generateButton;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *primeNumbersArray;
@property (nonatomic) NSInteger limit;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

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

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        NSLog(@"Landscape left");
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        NSLog(@"Landscape right");
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        NSLog(@"Portrait");
    } else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        NSLog(@"Upside down");
    }
}

#pragma mark - Text Field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [textField decimalCharacters:string];
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

@end
