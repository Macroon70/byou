//
//  BYCellPrototypeOrder.h
//  byou
//
//  Created by Peter on 2013.09.07..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYCellPrototypeOrder;

@protocol ByCellPrototypeOrderDelegate

-(void)valueChanged:(int)itemId withNewValue:(int)newValue;
-(void)orderStateChanged:(int)itemId withNewValue:(int)newValue;
-(void)showImageInBig:(NSString*)imgURL;

@end


@interface BYCellPrototypeOrder : UITableViewCell

@property (weak, nonatomic) id <ByCellPrototypeOrderDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIImageView *itemPic;
@property (weak, nonatomic) IBOutlet UILabel *itemNo;
@property (weak, nonatomic) IBOutlet UILabel *itemPieces;
@property (weak, nonatomic) IBOutlet UILabel *itemPiecesChecked;
@property (nonatomic, strong) NSString* imgURL;
@property int oriValue;
@property int newValue;
@property int orderId;
@property int state;

@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
- (IBAction)orderCollectionUp:(id)sender;
- (IBAction)orderCollectionDown:(id)sender;

@end
