//
//  BYCellPrototypeBasket.m
//  byou
//
//  Created by Peter on 2013.08.22..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

NSString*(^thousandSeparate2)(int) = ^(int number) {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    return [formatter stringFromNumber:[NSNumber numberWithInt:number]];
};

#import "BYCellPrototypeBasket.h"

@implementation BYCellPrototypeBasket

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

- (IBAction)addMoreItem:(id)sender {
    if (self.maxItemNum >= ++self.itemNum) {
        self.itemPieces.text = [NSString stringWithFormat:@"%d db",self.itemNum];
        self.itemSummPrice.text = [NSString stringWithFormat:@"Érték: %@ Ft",thousandSeparate2(self.itemNum * self.oriItemPrice)];
        [self.delegate valueChangedBasket:self.productId withNewValue:self.itemNum];
    }
}

- (IBAction)leftMoreItem:(id)sender {
    if (--self.itemNum >= 0) {
        self.itemPieces.text = [NSString stringWithFormat:@"%d db",self.itemNum];
        self.itemSummPrice.text = [NSString stringWithFormat:@"Érték: %@ Ft",thousandSeparate2(self.itemNum * self.oriItemPrice)];
        [self.delegate valueChangedBasket:self.productId withNewValue:self.itemNum];
    }
}
@end
