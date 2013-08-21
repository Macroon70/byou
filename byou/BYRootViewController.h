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

@interface BYRootViewController : UIViewController <BYProductFactoryDelegate, UIScrollViewDelegate, AddBasketProtocol, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) BYProductFactory* Products;

@property (nonatomic, strong) BYProductImagesScrollView* scrollView;
@property (nonatomic, strong) BYBasketView* basketView;
//@property (nonatomic, strong) BYBasketListViewController* basketListView;
@property (nonatomic, strong) UIPickerView* piecesPicker;

@property (nonatomic, strong) NSMutableArray* actualPieces;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
#pragma mark -
#pragma mark ViewControllers

#pragma mark -
#pragma mark Outlets
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIView *tableViews;


@end
