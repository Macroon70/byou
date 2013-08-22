//
//  BYProductImagesScrollView.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BYProductImagesScrollView.h"
#import "BYProduct.h"

@implementation BYProductImagesScrollView

@synthesize products;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

-(void)addProductsToView:(NSMutableArray *)dProducts {
    self.products = [NSMutableArray arrayWithArray:dProducts];
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    __block int iPos = 0;
    [self.products enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@",obj.imageURL);
        NSURL *url = [NSURL URLWithString:obj.imageURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0+iPos,0,self.bounds.size.width,self.bounds.size.height)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        iPos += self.bounds.size.width;
    }];
    self.contentSize = CGSizeMake(iPos,self.bounds.size.height - 56.0f);
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
