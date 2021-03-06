//
//  BYProductImagesScrollView.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BYProductImagesScrollView;

@protocol BYProductImageScrollViewDelegate

-(void)startZooming:(UIImageView*)imageContent;

@end


@interface BYProductImagesScrollView : UIScrollView <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

-(void)addProductsToView:(int)startPos;
-(void)createListView:(NSMutableArray*)dProducts;

@property (nonatomic, weak) id<BYProductImageScrollViewDelegate> sDelegate;

@property (nonatomic, retain) NSMutableArray* products;
@property BOOL inImgView;

@end
