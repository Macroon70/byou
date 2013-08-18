//
//  BYBasketView.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYProduct.h"

@protocol AddBasketProtocol
-(void)addBasketPushed;
-(void)basketPushed;
@end

@interface BYBasketView : UIView

@property int actualProduct;
@property (nonatomic, strong) UILabel *stockInfo;

@property (nonatomic, assign) id<AddBasketProtocol> delegateBasketAdd;

-(void)refreshBasketView:(BYProduct*)product withNum:(int)productNum;

@end
