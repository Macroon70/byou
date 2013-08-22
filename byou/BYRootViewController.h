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

@interface BYRootViewController : UIViewController <BYProductFactoryDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) BYProductFactory* Products;

@property (nonatomic, strong) BYProductImagesScrollView* scrollView;

@property (nonatomic, strong) NSMutableArray* actualPieces;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
#pragma mark -
#pragma mark ViewControllers
@property (weak, nonatomic) IBOutlet UITableView *tableViewCont;

#pragma mark -
#pragma mark Outlets
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIView *tableViews;

@property (weak, nonatomic) IBOutlet UIButton *back_button;
- (IBAction)back_pushed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *CategoryName;
@property (weak, nonatomic) IBOutlet UIView *CategoryCont;
- (IBAction)nextItem:(id)sender;
- (IBAction)prevItem:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *itemInfoCont;
@property (weak, nonatomic) IBOutlet UILabel *stockInfo;
@property (weak, nonatomic) IBOutlet UILabel *basketInfo;
- (IBAction)basketDec:(id)sender;
- (IBAction)basketInc:(id)sender;
- (IBAction)basketIncEnded:(id)sender;
- (IBAction)basketDecEnded:(id)sender;


@end
