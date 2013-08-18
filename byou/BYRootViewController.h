//
//  BYRootViewController.h
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYProductFactory.h"
#import "BYProductImagesScrollView.h"
#import "BYBasketView.h"
//#import "BYBasketListViewController.h"

@interface BYRootViewController : UIViewController <BYProductFactoryDelegate, UIScrollViewDelegate, AddBasketProtocol, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) BYProductFactory* Products;
@property (nonatomic, strong) BYProductImagesScrollView* scrollView;
@property (nonatomic, strong) BYBasketView* basketView;
//@property (nonatomic, strong) BYBasketListViewController* basketListView;
@property (nonatomic, strong) UIPickerView* piecesPicker;

@property (nonatomic, strong) NSMutableArray* actualPieces;

@end
