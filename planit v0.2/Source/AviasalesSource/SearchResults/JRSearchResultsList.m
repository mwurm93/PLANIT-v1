//
//  JRSearchResultsList.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "planit_v0_2-Swift.h"

#import "JRSearchResultsList.h"
#import "JRResultsTicketCell.h"

@implementation JRSearchResultsList

@synthesize ticketCellNibName = _ticketCellNibName;

- (instancetype)initWithCellNibName:(NSString *)cellNibName {
    if (self = [super init]) {
        _ticketCellNibName = cellNibName;
    }
    return self;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.delegate tickets].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"JRResultsTicketCell";

    JRResultsTicketCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[AVIASALES_BUNDLE loadNibNamed:self.ticketCellNibName owner:self options:nil] objectAtIndex:0];
    }
    cell.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.contentView.layer.backgroundColor = [UIColor clearColor].CGColor;
    cell.tintColor = [UIColor clearColor];
    cell.backgroundView = nil;
    
    cell.flightSegmentsLayoutParameters = self.flightSegmentLayoutParameters;
    cell.ticket = [self ticketAtIndexPath:indexPath];
    
    ConvertTicketForSavePerformer *convertTicketForSavePerformer = [[ConvertTicketForSavePerformer alloc] init];
    NSArray *savedFlightTickets = [convertTicketForSavePerformer fetchSavedFlightTickets];
    
    if ([convertTicketForSavePerformer checkIfSavedFlightTicketsContainsWithTicket:cell.ticket savedFlightTickets:savedFlightTickets] == 1) {
        [cell.saveButton setSelected:YES];
    }
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRSDKTicket *const ticket = [self ticketAtIndexPath:indexPath];
    return [JRResultsTicketCell heightWithTicket:ticket];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger index = indexPath.section;
    [self.delegate didSelectTicketAtIndex:index];
}

#pragma mark - Private

- (JRSDKTicket *)ticketAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger index = indexPath.section;
    return [[self.delegate tickets] objectAtIndex:index];
}

@end
