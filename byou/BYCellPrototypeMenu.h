//
//  BYCellPrototypeMenu.h
//  byou
//
//  Created by Peter on 2013.08.21..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BYCellPrototypeMenu : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *menuName;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *menuItemsLoading;

@end
