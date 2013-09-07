//
//  BYCellPrototypeBasket.h
//  byou
//
//  Created by Peter on 2013.08.22..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ByCellPrototypeBasketDelegate

-(void)valueChangedBasket:(NSString*)itemId withNewValue:(int)newValue;

@end

@interface BYCellPrototypeBasket : UITableViewCell

@property (weak, nonatomic) id<ByCellPrototypeBasketDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIImageView *itemPic;
@property (weak, nonatomic) IBOutlet UILabel *itemNo;
@property (weak, nonatomic) IBOutlet UILabel *itemPieces;
@property (weak, nonatomic) IBOutlet UILabel *itemPrice;
@property (weak, nonatomic) IBOutlet UILabel *itemSummPrice;
@property int itemNum;
@property int maxItemNum;
@property (strong, nonatomic) NSString* productId;
@property long oriItemPrice;
@property long oriItemSummPrice;
- (IBAction)addMoreItem:(id)sender;
- (IBAction)leftMoreItem:(id)sender;

@end
