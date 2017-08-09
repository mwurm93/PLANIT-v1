//
//  ASTSimpleSearchFormDateTableViewCell.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//
#import "planit_v0_2-Swift.h"

#import "ASTSimpleSearchFormDateTableViewCell.h"

@implementation ASTSimpleSearchFormDateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImageView.tintColor = [JRColorScheme searchFormTintColor];
    self.returnButton.tintColor = [JRColorScheme searchFormTintColor];
    self.returnLabel.textColor = [JRColorScheme searchFormTintColor];
    //[self handleReturnButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReturnButton)
                                                 name:@"oneWayButtonTouchedUpInside"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReturnButton)
                                                 name:@"roundtripButtonTouchedUpInside"
                                               object:nil];

}
- (IBAction)returnButtonTapped:(UIButton *)sender {
    if (self.returnButtonAction) {
        self.returnButtonAction(sender);
    }
}

- (void)handleReturnButton{
    
    FlightTicketsAccessoryMethodPerformer *flightTicketsAccessoryMethodPerformer = [[FlightTicketsAccessoryMethodPerformer alloc] init];
    bool isRoundtrip = [flightTicketsAccessoryMethodPerformer fetchIsRoundtrip];
    
    if( !isRoundtrip && self.tag == 0) {
        [self.returnButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        for (UIView *subview in self.subviews) {
            [subview setHidden:true];
        }
    } else if ( isRoundtrip && self.tag == 0) {
        for (UIView *subview in self.subviews) {
            [subview setHidden:false];
        }
    }
}


@end
