//
//  BYBasketView.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BYBasketView.h"

@implementation BYBasketView

@synthesize actualProduct;
@synthesize stockInfo;
@synthesize delegateBasketAdd = _delegateBasketAdd;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.8f;
        self.actualProduct = 0;
        self.stockInfo = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 15.0f, 200.0f, 40.0f)];
        self.stockInfo.backgroundColor = [UIColor clearColor];
        self.stockInfo.textColor = [UIColor whiteColor];
        [self addSubview:self.stockInfo];
        UIButton* addBasket = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addBasket = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        addBasket.frame = CGRectMake((float)(self.bounds.size.width / 2 - 50), 15.0f, 100.0f, 40.0f);
        [addBasket setTitle:@"KOSÁRBA" forState:UIControlStateNormal];
        [self addSubview:addBasket];
        [addBasket addTarget:self action:@selector(addBasketPushedIn) forControlEvents:UIControlEventTouchUpInside];
        UIButton* basket = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        basket.frame = CGRectMake((float)self.bounds.size.width - 130.0, 15.0f, 100.0f, 40.0f);
        [basket setTitle:@"KOSÁR" forState:UIControlStateNormal];
        [self addSubview:basket];
        [basket addTarget:self action:@selector(basketPushedIn) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}

-(void)refreshBasketView:(BYProduct *)product withNum:(int)productNum {
    if (productNum != self.actualProduct) {
        self.actualProduct = productNum;
        self.stockInfo.text = [NSString stringWithFormat:@"Készleten: %d",product.pieces];
    }
}

-(void)addBasketPushedIn {
    [self.delegateBasketAdd addBasketPushed];
}

-(void)basketPushedIn {
    [self.delegateBasketAdd basketPushed];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
