//
//  ASTContainerSearchFormViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "planit_v0_2-Swift.h"

#import "ASTContainerSearchFormViewController.h"
#import "ASTSimpleSearchFormViewController.h"
#import "ASTComplexSearchFormViewController.h"


NS_ENUM(NSInteger, ASTContainerSearchFormSearchType) {
    ASTContainerSearchFormSearchTypeOneWay = 0,
    ASTContainerSearchFormSearchTypeRoundtrip = 1,
    ASTContainerSearchFormSearchTypeComplex = 2
};


@interface ASTContainerSearchFormViewController () <HotelsSearchDelegate> 

@property (weak, nonatomic) IBOutlet UISegmentedControl *searchFormTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *alreadyHaveFlightsButton;
@property (weak, nonatomic) IBOutlet UIButton *comeBackToThisButton;

@property (nonatomic, strong) ASTSimpleSearchFormViewController *simpleSearchFormViewController;
@property (nonatomic, strong) ASTComplexSearchFormViewController *complexSearchFormViewController;

@property (nonatomic, weak) UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *currentChildViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchButtonBottomLayoutConstraint;

@end

@implementation ASTContainerSearchFormViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [InteractionManager shared].ticketsSearchForm = self;
    [self setupViewController];
    [self showChildViewController:self.simpleSearchFormViewController];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.searchButtonBottomLayoutConstraint.constant = 100;
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"flightSearchFormViewViewController_ViewDidAppear"
                                                        object:self];
}

#pragma mark - Setup

- (void)setupViewController {
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self setupNavigationItems];
    [self setupSegmentedControl];
    [self setupSearchButton];
    [self setupChildViewControllers];
    [self setupAlreadyHaveFlightsButton];
    [self setupComeBackToThisButton];

}

- (void)setupSegmentedControl {
    self.searchFormTypeSegmentedControl.tintColor = [JRColorScheme searchFormTintColor];
//    [self.searchFormTypeSegmentedControl setTitle:NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_SEGMENT_TITLE") forSegmentAtIndex:ASTContainerSearchFormSearchTypeSimple];
//    [self.searchFormTypeSegmentedControl setTitle:NSLS(@"JR_SEARCH_FORM_COMPLEX_SEARCH_SEGMENT_TITLE") forSegmentAtIndex:ASTContainerSearchFormSearchTypeComplex];
}

- (void)setupSearchButton {
    self.searchButton.tintColor = [JRColorScheme mainButtonTitleColor];
    self.searchButton.backgroundColor = [UIColor clearColor];
    self.searchButton.layer.cornerRadius = 20.0;
    self.searchButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.searchButton.layer.borderWidth = 1;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLS(@"JR_SEARCH_FORM_SEARCH_BUTTON") attributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIText-Bold" size:16.0]}];
    [self.searchButton setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (void)setupAlreadyHaveFlightsButton {
    self.alreadyHaveFlightsButton.tintColor = [UIColor lightGrayColor];
    self.alreadyHaveFlightsButton.backgroundColor = [UIColor clearColor];
    self.alreadyHaveFlightsButton.layer.cornerRadius = 15.0;
    self.alreadyHaveFlightsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.alreadyHaveFlightsButton.layer.borderWidth = 1;
}

- (void)setupComeBackToThisButton {
    self.comeBackToThisButton.tintColor = [UIColor lightGrayColor];
    self.comeBackToThisButton.backgroundColor = [UIColor clearColor];
    self.comeBackToThisButton.layer.cornerRadius = 15.0;
    self.comeBackToThisButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.comeBackToThisButton.layer.borderWidth = 1;
}



- (void)setupNavigationItems {
    
    UIViewController *tripViewControllerAsViewController = self.parentViewController.parentViewController;
    ObjCAccessoryMethods *objCAccessoryMethods = [[ObjCAccessoryMethods alloc] init];
    TripViewController *tripViewController = [objCAccessoryMethods getTripViewControllerWithViewController:tripViewControllerAsViewController];
    tripViewController.navigationItem.titleView = nil;
    tripViewController.navigationItem.title = NSLS(@"JR_SEARCH_FORM_TITLE");
    tripViewController.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
    
//    self.navigationItem.title = NSLS(@"JR_SEARCH_FORM_TITLE");
//    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
}

- (void)setupChildViewControllers {
    self.simpleSearchFormViewController = [[ASTSimpleSearchFormViewController alloc] init];
    self.complexSearchFormViewController = [[ASTComplexSearchFormViewController alloc] init];
}

#pragma mark - Container Managment

- (void)showSimpleSearchForm {
    [self switchViewController:self.complexSearchFormViewController toViewController:self.simpleSearchFormViewController];
}

- (void)showComplexSearchForm {
    [self switchViewController:self.simpleSearchFormViewController toViewController:self.complexSearchFormViewController];
}

- (void)switchViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewControllerToHide toViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewControllerToShow {
    [self hideChildViewController:viewControllerToHide];
    [self showChildViewController:viewControllerToShow];
}

- (void)hideChildViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)showChildViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewController {
    [self addChildViewController:viewController];
    viewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentChildViewController = viewController;
}

#pragma mark - Actions
- (IBAction)iAlreadyHaveFlightsButtonTouchedUpInside:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iAlreadyHaveFlightsButtonTouchedUpInside"                                  object:self];
}
- (IBAction)comeBackToThisButtonTouchedUpInside:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"comeBackToThisFlightsButtonTouchedUpInside"                                  object:self];
}

- (IBAction)searchFormTypeSegmentChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case ASTContainerSearchFormSearchTypeOneWay:
            [self showSimpleSearchForm];
            break;
        case ASTContainerSearchFormSearchTypeRoundtrip:
            [self showSimpleSearchForm];
            break;
        case ASTContainerSearchFormSearchTypeComplex:
            [self showComplexSearchForm];
            break;
    }
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    NSString *currencyCode = [[InteractionManager shared].currency.code lowercaseString];
    if (![currencyCode isEqualToString:[AviasalesSDK sharedInstance].currencyCode]) {
        [[AviasalesSDK sharedInstance] updateCurrencyCode:currencyCode];
    }
    [self.currentChildViewController performSearch];
}

#pragma mark - HotelsSearchDelegate

- (void)updateSearchInfoWithDestination:(JRSDKAirport *)destination checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut passengers:(ASTPassengersInfo *)passengers {
    [self showSimpleSearchForm];
    [self.searchFormTypeSegmentedControl setSelectedSegmentIndex:ASTContainerSearchFormSearchTypeRoundtrip];
    [self.simpleSearchFormViewController updateSearchInfoWithDestination:destination checkIn:checkIn checkOut:checkOut passengers:passengers];
//    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.tabBarController setSelectedViewController:self.navigationController];
}

@end
