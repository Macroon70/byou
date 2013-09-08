//
//  BYOrder.h
//  byou
//
//  Created by Peter on 2013.09.07..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYOrder : NSObject

@property (nonatomic, retain) NSString* itemCategory;
@property (nonatomic, retain) NSString* itemNo;
@property int itemId;
@property (nonatomic, retain) NSString* itemImg;
@property int itemPrice;
@property int itemQuantity;
@property int itemQuantityRel;
@property int state;
@property int orderId;
@property NSString* orderDate;

@end
