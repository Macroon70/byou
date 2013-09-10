//
//  BYProductImagesScrollView.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYProductImagesScrollView : UIScrollView

-(void)addProductsToView:(int)startPos;
-(void)createListView:(NSMutableArray*)dProducts;

@property (nonatomic, retain) NSMutableArray* products;

@end
