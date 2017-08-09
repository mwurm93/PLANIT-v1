//
//  ASTSimpleSearchFormViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "planit_v0_2-Swift.h"

#import "ASTSimpleSearchFormViewController.h"
#import "ASTSimpleSearchFormViewControllerProtocol.h"
#import "ASTSimpleSearchFormPresenter.h"
#import "ASTSimpleSearchFormViewModel.h"

#import "ASTSimpleSearchFormSeparatorView.h"
#import "ASTSimpleSearchFormAirportTableViewCell.h"
#import "ASTSimpleSearchFormDateTableViewCell.h"
#import "ASTSearchFormPassengersView.h"

#import "JRAirportPickerVC.h"
#import "JRDatePickerVC.h"

static CGFloat const separatorLeftInset = 76.0;
static CGFloat const separatorRightInset = 20.0;


@interface ASTSimpleSearchFormViewController () <ASTSimpleSearchFormViewControllerProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ASTSearchFormPassengersView *passengersView;
@property (weak, nonatomic) IBOutlet UIButton *swapButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swapButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengersViewHeightConstraint;

@property (nonatomic, strong) ASTSimpleSearchFormPresenter *presenter;
@property (nonatomic, strong) ASTSimpleSearchFormViewModel *viewModel;

@property (nonatomic, assign) CGFloat tableViewSectionHeaderHeight;
@property (nonatomic, assign) CGFloat tableViewSectionFooterHeight;
@property (nonatomic, assign) CGFloat tableViewRowHeight;
@property (nonatomic, assign) CGFloat swapButtonTopInsetDelta;

@end

@implementation ASTSimpleSearchFormViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _presenter = [[ASTSimpleSearchFormPresenter alloc] initWithViewController:self];
    }
    return self;
}

#pragma mark - Public

- (void)updateSearchInfoWithDestination:(JRSDKAirport *)destination checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut passengers:(ASTPassengersInfo *)passengers {
    [self.presenter updateSearchInfoWithDestination:destination checkIn:checkIn checkOut:checkOut passengers:passengers];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    //start with not roundtrip
    FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
    [flightTicketsAccessoryMethodPerformer saveIsRoundTripWithIsRoundtrip:NO];
    [_tableView reloadData];

    [self setupViewController];
    [self.presenter handleViewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideReturnButtonForOneWaySearch)
                                                 name:@"oneWayButtonTouchedUpInside"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showReturnButtonForRoundtripSearch)
                                                 name:@"roundtripButtonTouchedUpInside"
                                               object:nil];
    
    NSInteger indexOfDestinationBeingPlanned = [flightTicketsAccessoryMethodPerformer fetchIndexOfDestinationBeingPlanned];
    NSInteger numberDestinationsForTrip = [flightTicketsAccessoryMethodPerformer fetchNumberDestinationsForTrip];
    
    //Prefill dates
    NSDate *departureDate = [flightTicketsAccessoryMethodPerformer fetchDepartureDate];
    [_presenter handleSelectDate:departureDate withMode:0];
    
    //Prefill locations
    if (indexOfDestinationBeingPlanned == 0) {
        
        if ([flightTicketsAccessoryMethodPerformer checkIfStartingPointAirportFound]) {
            //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
            JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchStartingPointAirport];
            [_presenter handleSelectAirport:nearbyAirport withMode:0];
        }
        if ([flightTicketsAccessoryMethodPerformer checkIfDestinationAirportFoundWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned]) {
            //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
            JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchDestinationAirportWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned];
            [_presenter handleSelectAirport:nearbyAirport withMode:1];
        }
    }
    // return travel back to final destination (home)
    else if (indexOfDestinationBeingPlanned == numberDestinationsForTrip) {
        if ([flightTicketsAccessoryMethodPerformer checkIfDifferentEndingPoint]) {
            if ([flightTicketsAccessoryMethodPerformer checkIfDestinationAirportFoundWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned - 1]) {
                //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
                JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchDestinationAirportWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned - 1];
                [_presenter handleSelectAirport:nearbyAirport withMode:0];
            }
            if ([flightTicketsAccessoryMethodPerformer checkIfEndingPointAirportFound]) {
                //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
                JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchEndingPointAirport];
                [_presenter handleSelectAirport:nearbyAirport withMode:1];
            }

        } else {
            if ([flightTicketsAccessoryMethodPerformer checkIfDestinationAirportFoundWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned - 1]) {
                //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
                JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchDestinationAirportWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned - 1];
                [_presenter handleSelectAirport:nearbyAirport withMode:0];
            }
            if ([flightTicketsAccessoryMethodPerformer checkIfStartingPointAirportFound]) {
                //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
                JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchStartingPointAirport];
                [_presenter handleSelectAirport:nearbyAirport withMode:1];
            }
        }
    } else {
        if ([flightTicketsAccessoryMethodPerformer checkIfDestinationAirportFoundWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned - 1]) {
            //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
            JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchDestinationAirportWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned - 1];
            [_presenter handleSelectAirport:nearbyAirport withMode:0];
        }
        if ([flightTicketsAccessoryMethodPerformer checkIfDestinationAirportFoundWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned]) {
            //JRAirportPickerMode *mode = JRAirportPickerOriginMode;
            JRSDKAirport *nearbyAirport = [flightTicketsAccessoryMethodPerformer fetchDestinationAirportWithIndexOfDestinationBeingPlanned:indexOfDestinationBeingPlanned];
            [_presenter handleSelectAirport:nearbyAirport withMode:1];
        }
    }
    
}



- (void)hideReturnButtonForOneWaySearch {
    FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
    [flightTicketsAccessoryMethodPerformer saveIsRoundTripWithIsRoundtrip:NO];
}
- (void)showReturnButtonForRoundtripSearch {
    FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
    [flightTicketsAccessoryMethodPerformer saveIsRoundTripWithIsRoundtrip:YES];
    
    NSDate *returnDate = [flightTicketsAccessoryMethodPerformer fetchReturnDate];
    [_presenter handleSelectDate:returnDate withMode:1];

}



#pragma mark - Setup

- (void)setupViewController {
    [self setupLayoutVariables];
    [self setupTableView];
    [self setupSwapButton];
   // [self handleReturnButton];
}

- (void)setupLayoutVariables {
    self.tableViewSectionHeaderHeight = deviceSizeTypeValue(1.0, 5.0, 5.0, 5.0, 5.0);
    self.tableViewSectionFooterHeight = deviceSizeTypeValue(5.0, 10.0, 20.0, 20.0, 20.0);
    self.tableViewRowHeight = deviceSizeTypeValue(55.0, 60.0, 65.0, 65.0, 65.0);
    self.swapButtonTopInsetDelta = deviceSizeTypeValue(14.0, 10.0, 8.0, 8.0, 8.0);
    self.passengersViewHeightConstraint.constant = deviceSizeTypeValue(45.0, 55.0, 85.0, 95.0, 95.0);
}

- (void)setupTableView {
    self.tableView.rowHeight = self.tableViewRowHeight;
}

- (void)setupSwapButton {
    self.swapButton.tintColor = [JRColorScheme searchFormTintColor];
    self.swapButtonTopConstraint.constant = self.tableViewSectionHeaderHeight + self.tableViewRowHeight + self.swapButtonTopInsetDelta - CGRectGetHeight(self.swapButton.bounds) / 2.0;
}

#pragma makr - Update

- (void)updatePassengersView {
    
    ASTSimpleSearchFormPassengersViewModel *passengersViewModel = self.viewModel.passengersViewModel;
    
    self.passengersView.adultsLabel.text = passengersViewModel.adults;
    self.passengersView.childrenLabel.text = passengersViewModel.children;
    self.passengersView.infantsLabel.text = passengersViewModel.infants;
    self.passengersView.travelClassLabel.text = passengersViewModel.travelClass;
    
    __weak typeof(self) weakSelf = self;
    self.passengersView.tapAction = ^(UIView *sender) {
        [weakSelf.presenter handlePickPassengers];
    };
}

#pragma mark - ASTSimpleSearchFormViewControllerProtocol

- (void)updateWithViewModel:(ASTSimpleSearchFormViewModel *)viewModel {
    self.viewModel = viewModel;
    [self.tableView reloadData];
    [self updatePassengersView];
}

- (void)showAirportPickerWithMode:(JRAirportPickerMode)mode {
    [self showAirportPickerViewControllerWithMode:mode];
}
- (void)showDatePickerWithMode:(JRDatePickerMode)mode borderDate:(NSDate *)borderDate firstDate:(NSDate *)firstDate secondDate:(NSDate *)secondDate {
    [self showDatePickerViewControllerWithMode:mode borderDate:borderDate firstDate:firstDate secondDate:secondDate];
}

- (void)showPassengersPickerWithInfo:(ASTPassengersInfo *)passengersInfo {
    [self showPassengersPickerViewControllerWithInfo:passengersInfo];
}

- (void)showErrorWithMessage:(NSString *)message {
    [self showErrorAlertWithMessage:message];
}

- (void)showWaitingScreenWithSearchInfo:(JRSDKSearchInfo *)searchInfо {
    [self showWaitingScreenViewControllerWithSeachInfo:searchInfо];
}

#pragma mark - ASTContainerSearchFormChildViewControllerProtocol

- (void)performSearch {
    [self.presenter handleSearch];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return self.viewModel.sectionViewModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.sectionViewModels[section].cellViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASTSimpleSearchFormCellViewModel *cellViewModel = self.viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row];
    UITableViewCell *cell = [self buildCellFromCellViewModel:cellViewModel];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heightForRow = self.tableViewRowHeight;
    
    return heightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _tableViewSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.tableViewSectionFooterHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ASTSimpleSearchFormSeparatorView *separatorView = [[ASTSimpleSearchFormSeparatorView alloc] init];
    separatorView.style = ASTSearchFormSeparatorViewStyleBottom;
    separatorView.leftInset = separatorLeftInset;
    separatorView.rightInset = separatorRightInset;
    separatorView.backgroundColor = [UIColor clearColor];
    separatorView.separatorColor = [UIColor whiteColor];
    return separatorView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ASTSimpleSearchFormCellViewModel *cellViewModel = self.viewModel.sectionViewModels[indexPath.section].cellViewModels[indexPath.row];
    [self.presenter handleSelectCellViewModel:cellViewModel];
}

#pragma mark - Cells

- (UITableViewCell *)buildCellFromCellViewModel:(ASTSimpleSearchFormCellViewModel *)cellViewModel {
    switch (cellViewModel.type) {
        case ASTSimpleSearchFormCellViewModelTypeOrigin:
        case ASTSimpleSearchFormCellViewModelTypeDestination:
            return [self buildAirportCellFromCellViewModel:(ASTSimpleSearchFormAirportCellViewModel *)cellViewModel];
            break;
        case ASTSimpleSearchFormCellViewModelTypeDeparture:
        case ASTSimpleSearchFormCellViewModelTypeReturn:
            return [self buildDateCellFromCellViewModel:(ASTSimpleSearchFormDateCellViewModel *)cellViewModel];
            break;
    }
}

- (ASTSimpleSearchFormAirportTableViewCell *)buildAirportCellFromCellViewModel:(ASTSimpleSearchFormAirportCellViewModel *)cellViewModel {
    
    ASTSimpleSearchFormAirportTableViewCell *cell = [ASTSimpleSearchFormAirportTableViewCell loadFromNib];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.cityLabel.alpha = cellViewModel.placeholder ? 0.6 : 1.0;
    cell.iconImageView.image = [UIImage imageNamed:cellViewModel.icon];
    cell.hintLabel.text = cellViewModel.hint;
    cell.cityLabel.text = cellViewModel.city;
    cell.iataLabel.text = cellViewModel.iata;
    
    return cell;
}

- (ASTSimpleSearchFormDateTableViewCell *)buildDateCellFromCellViewModel:(ASTSimpleSearchFormDateCellViewModel *)cellViewModel {
    
    ASTSimpleSearchFormDateTableViewCell *cell = [ASTSimpleSearchFormDateTableViewCell loadFromNib];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.dateLabel.alpha = cellViewModel.placeholder ? 0.6 : 1.0;
    cell.iconImageView.image = [UIImage imageNamed:cellViewModel.icon];
    cell.hintLabel.text = cellViewModel.hint;
    cell.dateLabel.text = cellViewModel.date;
    cell.returnButton.hidden = cell.returnLabel.hidden = cellViewModel.shouldHideReturnCheckbox;
    cell.returnButton.selected = cellViewModel.shouldSelectReturnCheckbox;
    BOOL isDeparture = cellViewModel.type == ASTSimpleSearchFormCellViewModelTypeDeparture;
    if (isDeparture) {
        cell.tag = 1;
    } else {
        cell.tag = 0;
    }

    FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
    bool isRoundtrip = [flightTicketsAccessoryMethodPerformer fetchIsRoundtrip];

    if( !isRoundtrip && cell.tag == 0) {
        [cell.returnButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        for (UIView *subview in cell.subviews) {
            [subview setHidden:true];
        }
    } else if ( isRoundtrip && cell.tag == 0) {
        for (UIView *subview in cell.subviews) {
            [subview setHidden:false];
        }
    }
    __weak typeof(self) weakSelf = self;
    cell.returnButtonAction = ^(UIButton *sender) {
        [weakSelf.presenter handleSwitchReturnCheckbox];
    };
    
    return cell;
}

#pragma mark - Navigation

- (void)showAirportPickerViewControllerWithMode:(JRAirportPickerMode)mode {
    
    __weak typeof(self) weakSelf = self;
    
    JRAirportPickerVC *airportPickerViewController = [[JRAirportPickerVC alloc] initWithMode:mode selectionBlock:^(JRSDKAirport *selectedAirport) {
        [weakSelf.presenter handleSelectAirport:selectedAirport withMode:mode];
        
    }];
    
    [self pushOrPresentBasedOnDeviceTypeWithViewController:airportPickerViewController animated:YES];
}

- (void)showDatePickerViewControllerWithMode:(JRDatePickerMode)mode borderDate:(NSDate *)borderDate firstDate:(NSDate *)firstDate secondDate:(NSDate *)secondDate {
    
    __weak typeof(self) weakSelf = self;
    
    JRDatePickerVC *datePickerViewController = [[JRDatePickerVC alloc] initWithMode:mode borderDate:borderDate firstDate:firstDate secondDate:secondDate selectionBlock:^(NSDate *selectedDate) {
        [weakSelf.presenter handleSelectDate:selectedDate withMode:mode];
    }];
    
    [self pushOrPresentBasedOnDeviceTypeWithViewController:datePickerViewController animated:YES];
}

- (void)showPassengersPickerViewControllerWithInfo:(ASTPassengersInfo *)passengersInfo {
    
    __weak typeof(self) weakSelf = self;
    
    ASTPassengersPickerViewController *passengersPickerViewController = [[ASTPassengersPickerViewController alloc] initWithPassengersInfo:passengersInfo selection:^(ASTPassengersInfo *selectedPassengersInfo) {
        [weakSelf.presenter handleSelectPassengersInfo:selectedPassengersInfo];
    }];
    
    passengersPickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    passengersPickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:passengersPickerViewController animated:YES completion:nil];
}

- (void)showWaitingScreenViewControllerWithSeachInfo:(JRSDKSearchInfo *)searchInfo {
    ASTWaitingScreenViewController *waitingScreenViewController = [[ASTWaitingScreenViewController alloc] initWithSearchInfo:searchInfo];
    [self.navigationController pushViewController:waitingScreenViewController animated:NO];
}

#pragma mark - Actions

- (IBAction)swapButtonTapped:(UIButton *)sender {
    [self.presenter handleSwapAirports];
}

@end
