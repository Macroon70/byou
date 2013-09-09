//
//  BYCellPrototypeOrder.m
//  byou
//
//  Created by Peter on 2013.09.07..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BYCellPrototypeOrder.h"

@implementation BYCellPrototypeOrder

@synthesize oriValue, newValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)imageTapped:(UITapGestureRecognizer*)gestureRecognizer {
    [self.delegate showImageInBig:self.imgURL];
}


- (IBAction)orderCollectionUp:(id)sender {
    if (self.oriValue > self.newValue) {
        self.itemPiecesChecked.text = [NSString stringWithFormat:@"%d db",++self.newValue];
        [self.delegate valueChanged:self.orderId withNewValue:self.newValue];
    }
}

- (IBAction)orderCollectionDown:(id)sender {
    if (self.newValue > 0) {
        self.itemPiecesChecked.text = [NSString stringWithFormat:@"%d db",--self.newValue];
        [self.delegate valueChanged:self.orderId withNewValue:self.newValue];
    }
}
@end
