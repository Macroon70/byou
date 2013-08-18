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

-(void)addProductsToView:(NSMutableDictionary *)dProducts {
    self.products = dProducts;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    __block int iPos = 0;
    [self.products enumerateKeysAndObjectsUsingBlock:^(NSString* key, BYProduct* obj, BOOL *stop) {
        NSURL *url = [NSURL URLWithString:obj.imageURL];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0+iPos,0,bounds.size.width,bounds.size.height)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        iPos += bounds.size.width;
    }];
    self.contentSize = CGSizeMake(iPos,bounds.size.height);
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
