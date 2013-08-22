//
//  BYRootViewController.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

#import "BYRootViewController.h"
#import "BYCellPrototypeLogin.h"
#import "BYCellPrototypeMenu.h"
#import "BYCellPrototypeBasket.h"
#import "BYMenu.h"
#import "BYProduct.h"

@interface BYRootViewController ()

@end


@implementation BYRootViewController {
    UIActivityIndicatorView* loginAct;
    UIActivityIndicatorView* menuAct;
    NSString* menuName;
    NSString* tableVersion;
    
    NSTimer* repeatTimer;
}

@synthesize Products;
@synthesize scrollView;
@synthesize actualPieces;
@synthesize tableViewCont;

@synthesize userName;

@synthesize tableViews;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.Products = [[BYProductFactory alloc] init];
    self.Products.delegate = self;
    tableVersion = @"Login";
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserName:nil];
    [self setTableViews:nil];
    [self setStatusLabel:nil];
    [self setTableViewCont:nil];
    [self setBack_button:nil];
    [self setCategoryName:nil];
    [self setCategoryCont:nil];
    [self setStockInfo:nil];
    [self setBasketInfo:nil];
    [self setItemInfoCont:nil];
    [super viewDidUnload];
}


#pragma mark - Catalog Methods

-(void)setStockInfoLabel:(int)position {
    BYProduct *actualProduct = [self.Products getProductForm:position];
    self.stockInfo.text = [NSString stringWithFormat:@"%d",actualProduct.pieces];
    self.basketInfo.text = [NSString stringWithFormat:@"%d", actualProduct.basket];
}

#pragma mark - self delegates

-(IBAction)back_pushed:(id)sender {
    self.back_button.hidden = YES;
    self.CategoryCont.hidden = YES;
    self.itemInfoCont.hidden = YES;
    [self.Products sendBasketInfoToDict:menuName];
    [self.scrollView removeFromSuperview];
}

- (IBAction)nextItem:(id)sender {
    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x = currentOffset.x + self.view.bounds.size.width;
    if (self.scrollView.contentSize.width > currentOffset.x)
        [self.scrollView setContentOffset:currentOffset animated:YES];
}

- (IBAction)prevItem:(id)sender {
    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x = currentOffset.x - self.view.bounds.size.width;
    if (currentOffset.x >= 0)
        [self.scrollView setContentOffset:currentOffset animated:YES];
}

-(void)timerMethodForBasket:(NSTimer*)timer {
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    [self.Products setProductValues:pageNum direction:[timer userInfo]];
    [self setStockInfoLabel:pageNum];
}

- (IBAction)basketDec:(id)sender {
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    [self.Products setProductValues:pageNum direction:@"DOWN"];
    [self setStockInfoLabel:pageNum];
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                   target:self
                                                 selector:@selector(timerMethodForBasket:)
                                                 userInfo:@"DOWN"
                                                  repeats:YES];
}

- (IBAction)basketInc:(id)sender {
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    [self.Products setProductValues:pageNum direction:@"UP"];
    [self setStockInfoLabel:pageNum];
    repeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                   target:self
                                                 selector:@selector(timerMethodForBasket:)
                                                 userInfo:@"UP"
                                                  repeats:YES];
}

- (IBAction)basketIncEnded:(id)sender {
    [repeatTimer invalidate];
    repeatTimer = nil;
}

- (IBAction)basketDecEnded:(id)sender {
    [repeatTimer invalidate];
    repeatTimer = nil;
}


#pragma mark - Factory Delegates

-(void)loginDidFinish {
    self.statusLabel.text = self.Products.loginMessage;
    self.statusLabel.textColor = self.Products.loginMessageColor;
    [loginAct stopAnimating];
    if ([self.Products.menus count] != 0) {
        tableVersion = @"Menu";
        [self.tableViewCont reloadData];
    }
}

-(void)collectionDidFinish {
    self.scrollView = [[BYProductImagesScrollView alloc] initWithFrame:CGRectMake(0.0f, 56.0f, self.view.bounds.size.width, self.view.bounds.size.height - 56.0f)];
    self.scrollView.delegate = self;
    self.back_button.hidden = NO;
    self.CategoryCont.hidden = NO;
    self.itemInfoCont.hidden = NO;
    self.CategoryName.text = menuName;
    [menuAct stopAnimating];
    [self.Products getBasketInfoFromDict:menuName];
    [self setStockInfoLabel:0];
    [self.scrollView addProductsToView:self.Products.products];
    [self.view insertSubview:self.scrollView belowSubview:self.CategoryCont];
    
}

#pragma mark - ScrollView Delegates

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    [self setStockInfoLabel:pageNum];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableVersion isEqualToString:@"Login"]) return 1;
    if ([tableVersion isEqualToString:@"Menu"]) return 3;
    if ([tableVersion isEqualToString:@"Basket"]) return 2;
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableVersion isEqualToString:@"Login"]) return 3;
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (section == 0) return [self.Products.menus count];
        if (section == 1) return 1;
        if (section == 2) return 1;
    }
    if ([tableVersion isEqualToString:@"Basket"]) {
        if (section == 0) return [self.Products.basket count] + 1;
        if (section == 1) {
            if ([self.Products.basket count] == 0) {
                return 1;
            } else {
                return 2;
            }
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableVersion isEqualToString:@"Basket"] && indexPath.section == 0 && indexPath.row > 0) {
        return 76.0f;
    }
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableVersion isEqualToString:@"Login"]) {
        if (indexPath.row == 2) {
            static NSString *cellIndetifier = @"LoginSend";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier forIndexPath:indexPath];
            loginAct = (UIActivityIndicatorView*)[cell viewWithTag:1];
            return cell;
        } else {
            static NSString *CellIdentifier = @"LoginCell";
            BYCellPrototypeLogin *cell = (BYCellPrototypeLogin *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[BYCellPrototypeLogin alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
    
            switch (indexPath.row) {
                case 0:
                    cell.label.text = @"Felhasználó";
                    break;
                case 1:
                    cell.label.text = @"Jelszó";
                    cell.aTextField.secureTextEntry = YES;
                    break;
            }
            return cell;
        }
    }
    
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (indexPath.section == 0) {
            static NSString *cellIdentifier = @"MenuCell";
            BYCellPrototypeMenu *cell = (BYCellPrototypeMenu*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                                          forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[BYCellPrototypeMenu alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.menuName.text = [(BYMenu*)[self.Products.menus objectAtIndex:indexPath.row] menuName];
            return cell;
        }
        if (indexPath.section == 1) {
            static NSString *cellIdentifier = @"BasketCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
        if (indexPath.section == 2) {
            static NSString *cellIdentifier = @"SignOutCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        }
    }
    
    if ([tableVersion isEqualToString:@"Basket"]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                static NSString *cellIdentifier = @"SummCell";
                BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                if ([self.Products.basket count] == 0) {
                    cell.itemName.text = @"Az Ön kosara üres";
                } else {
                    cell.itemName.text = [NSString stringWithFormat:@"Összesen: %d db",[self.Products BasketItemsSumm]];
                }
                return cell;
            } else {
                static NSString *cellIdentifier = @"ItemDetailsCell";
                BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                BYProduct *cellProduct = [self.Products.basket objectForKey:[self.Products.allBasketKeys objectAtIndex:indexPath.row-1]];
                cell.itemName.text = cellProduct.CategoryName;
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cellProduct.imageURL]];
                cell.itemPic.image = [UIImage imageWithData:imageData];
                cell.itemPieces.text = [NSString stringWithFormat:@"%d db",cellProduct.basket];
                return cell;
            }
        }
        if (indexPath.section == 1 && [self.Products.basket count] == 0) {
            static NSString *cellIdentifier = @"BackCell";
            BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            return cell;
        } else {
            if (indexPath.row == 0) {
                static NSString *cellIdentifier = @"PlaceOrderCell";
                BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                return cell;
            } else {
                static NSString *cellIdentifier = @"BackCell";
                BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                return cell;
            }
        }
        
    }
    
    return nil;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableVersion isEqualToString:@"Login"]) {
        if (indexPath.row == 2) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            BYCellPrototypeLogin *cellAuth = (BYCellPrototypeLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:indexPath.section]];
            BYCellPrototypeLogin *cellName = (BYCellPrototypeLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
            [self.Products authLoginName:cellName.aTextField.text withPass:cellAuth.aTextField.text];
            cellAuth.aTextField.text = @"";
            cellName.aTextField.text = @"";
            [loginAct startAnimating];
            [self.view endEditing:YES];
        }
        return;
    }
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (indexPath.row == 0 && indexPath.section == 2) {
            tableVersion = @"Login";
            [self.tableViewCont reloadData];
            self.statusLabel.text = @"";
        }
        
        if (indexPath.section == 0) {
            BYCellPrototypeMenu *clickedCell = (BYCellPrototypeMenu*)[tableView cellForRowAtIndexPath:indexPath];
            menuAct = clickedCell.menuItemsLoading;
            menuName = clickedCell.menuName.text;
            [menuAct startAnimating];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.Products getMenuContents:indexPath.row];
        }
        if (indexPath.section == 1) {
            BYCellPrototypeMenu *clickedCell = (BYCellPrototypeMenu*)[tableView cellForRowAtIndexPath:indexPath];
            [clickedCell.menuItemsLoading startAnimating];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            tableVersion = @"Basket";
            [self.tableViewCont reloadData];
            [clickedCell.menuItemsLoading stopAnimating];
        }
        return;
    }
    if ([tableVersion isEqualToString:@"Basket"]) {
        if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"BackCell"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            tableVersion = @"Menu";
            [self.tableViewCont reloadData];
        }
        if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"PlaceOrderCell"]) {
            [self.Products PlaceOrder];
            [self.tableViewCont reloadData];
        }
        return;
    }
}


@end
