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

-(void)createListView:(NSMutableArray *)dProducts {
    self.products = [NSMutableArray arrayWithArray:dProducts];
    self.contentSize = CGSizeMake(self.bounds.size.width,((int)ceilf([dProducts count] /2) * 300) + 100);
    [self.products enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
        int leftPos = (idx % 2) ? 428 : 89;
        int topPos = 100 + ((int)roundf(idx / 2) * 300);
        NSString* str = [[NSString stringWithFormat:@"%@.jpg",obj.imageURL]
                         stringByReplacingOccurrencesOfString:@"origs"
                         withString:@"thumbs"];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
        __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPos,topPos,250.0f,250.0f)];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imageView.image = [UIImage imageWithData:data];
        }];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(showProductView:)];
        [imageView addGestureRecognizer:tap];
        imageView.tag = idx;
        [self addSubview:imageView];
    }];
    NSLog(@"%d",(int)ceilf([dProducts count] /2) * 2000);
}

-(void)addProductsToView:(int)startPos {
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    __block int iPos = 0;
    [self.products enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
        NSString* str = [NSString stringWithFormat:@"%@.jpg",obj.imageURL];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
        __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0+iPos,0,self.bounds.size.width,self.bounds.size.height)];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"]];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            imageView.image = [UIImage imageWithData:data];
        }];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        iPos += self.bounds.size.width;
    }];
    self.contentSize = CGSizeMake(iPos,self.bounds.size.height - 56.0f);
    CGPoint scrollPoint = CGPointMake( 0 + (self.bounds.size.width * startPos), 0.0f);
    [self setContentOffset:scrollPoint animated:YES];
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
