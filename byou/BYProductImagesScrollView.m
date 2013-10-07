//
//  BYProductImagesScrollView.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BYProductImagesScrollView.h"
#import "BYProduct.h"

@implementation BYProductImagesScrollView {
    BOOL thumbsLoaded;
    BOOL imgLoaded;
    CGSize thumbView;
    CGSize imgView;
}

@synthesize products;
@synthesize inImgView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        thumbsLoaded = NO;
        imgLoaded = NO;
        self.inImgView = NO;
    }
    return self;
}

-(void)createListView:(NSMutableArray *)dProducts {
    if (!thumbsLoaded) {
        self.products = [NSMutableArray arrayWithArray:dProducts];
        self.contentSize = CGSizeMake(self.bounds.size.width,((int)ceilf([dProducts count] /4) * 192) + 70);
        thumbView = self.contentSize;
        [self.products enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
            int leftPos = (idx % 2) ? 428 : 89;
            switch (idx % 4) {
                case 0:
                    leftPos = 1;
                    break;
                case 1:
                    leftPos = 193;
                    break;
                case 2:
                    leftPos = 385;
                    break;
                case 3:
                    leftPos = 577;
                    break;
                default:
                    break;
            }
            int topPos = 70 + ((int)roundf(idx / 4) * 192);
            NSString* str = [[NSString stringWithFormat:@"%@.jpg",obj.imageURL]
                             stringByReplacingOccurrencesOfString:@"origs"
                             withString:@"thumbs"];
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
            __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftPos,topPos,190.0f,190.0f)];
            [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                imageView.image = [UIImage imageWithData:data];
            }];
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(showProductView:)];
            [imageView addGestureRecognizer:tap];
            imageView.tag = idx + 1;
            [self addSubview:imageView];
            thumbsLoaded = YES;
        }];
    } else {
        for (UIImageView* view in self.subviews) {
            if (view.tag > 0) {
                view.hidden = NO;
                self.contentSize = thumbView;
            } else view.hidden = YES;
        }
    }
    self.inImgView = NO;
}

-(void)addProductsToView:(int)startPos {
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    __block int iPos = 0;
    for (UIImageView* view in self.subviews) {
        if (view.tag != 0) {
            view.hidden = YES;
        }
    }
    if (!imgLoaded) {
        [self.products enumerateObjectsUsingBlock:^(BYProduct* obj, NSUInteger idx, BOOL *stop) {
            NSString* str = [NSString stringWithFormat:@"%@.jpg",obj.imageURL];
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
            __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0+iPos,0,self.bounds.size.width,self.bounds.size.height)];
            __block UIImageView *sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 80 + iPos, 10, 70, 90)];
            sImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"search" ofType:@"png"]];
            sImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomTapped:)];
            [sImageView addGestureRecognizer:tap];
            imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"]];
            [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                imageView.image = [UIImage imageWithData:data];
            }];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = (idx + 1)*-1;
            [self addSubview:imageView];
            iPos += self.bounds.size.width;
            sImageView.tag = imageView.tag * 500;
            [self addSubview:sImageView];
        }];
        self.contentSize = CGSizeMake(iPos,self.bounds.size.height - 56.0f);
        imgView = self.contentSize;
        imgLoaded = YES;
    } else {
        for (UIImageView* view in self.subviews) {
            if (view.tag < 0) {
                view.hidden = NO;
                self.contentSize = imgView;
            }
        }
    }
    CGPoint scrollPoint = CGPointMake( 0 + (self.bounds.size.width * (startPos)), 0.0f);
    [self setContentOffset:scrollPoint animated:NO];
    self.inImgView = YES;

}

-(void)zoomTapped:(UIGestureRecognizer*)recognizer {
    [self.sDelegate startZooming:(UIImageView*)recognizer.view];
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
