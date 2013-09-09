//
//  BYRootViewController.m
//  byou
//
//  Created by Peter on 2013.08.11..
//  Copyright (c) 2013 LianDesign. All rights reserved.
//

NSString*(^thousandSeparate)(int) = ^(int number) {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@" "];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    return [formatter stringFromNumber:[NSNumber numberWithInt:number]];
};

#import "BYRootViewController.h"
#import "BYCellPrototypeLogin.h"
#import "BYCellPrototypeMenu.h"
#import "BYMenu.h"
#import "BYProduct.h"
#import "BYOrder.h"

@interface BYRootViewController ()

@end


@implementation BYRootViewController {
    UIActivityIndicatorView* loginAct;
    UIActivityIndicatorView* menuAct;
    NSString* menuName;
    NSString* tableVersion;
    NSTimer* repeatTimer;
    int isPlaceOrder;
    BOOL orderCellState;
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
    isPlaceOrder = 0;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBigPic:)];
    [self.itemBigPic addGestureRecognizer:tap];
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
    [self setRefreshButton:nil];
    [super viewDidUnload];
}


#pragma mark - Catalog Methods

-(void)setStockInfoLabel:(int)position {
    BYProduct *actualProduct = [self.Products getProductForm:position];
    self.stockInfo.text = [NSString stringWithFormat:@"%d",actualProduct.pieces];
    self.basketInfo.text = [NSString stringWithFormat:@"%d", actualProduct.basket];
}

#pragma mark - Order Methods

-(void)checkOrderCollectedButtonState {
    __block BOOL foundGrey = NO;
    [self.Products.actualOrderItems enumerateObjectsUsingBlock:^(BYOrder* obj, NSUInteger idx, BOOL *stop) {
        if (obj.state == 0) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            BYCellPrototypeBasket *cell = (BYCellPrototypeBasket*)[self.tableViewCont cellForRowAtIndexPath:indexPath];
            cell.userInteractionEnabled = NO;
            cell.itemName.textColor = [UIColor lightGrayColor];
            foundGrey = YES;
        }
    }];
    if (!foundGrey) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        BYCellPrototypeBasket *cell = (BYCellPrototypeBasket*)[self.tableViewCont cellForRowAtIndexPath:indexPath];
        cell.userInteractionEnabled = YES;
        cell.itemName.textColor = [UIColor blackColor];
    }
    orderCellState = foundGrey;
}

#pragma mark - self delegates

-(IBAction)back_pushed:(id)sender {
    self.back_button.hidden = YES;
    self.CategoryCont.hidden = YES;
    self.itemInfoCont.hidden = YES;
    self.refreshButton.hidden = NO;
    [self.Products sendBasketInfoToDict:menuName];
    [self.Products refreshMenu];
    [self.scrollView removeFromSuperview];
}

- (IBAction)refreshPushed:(id)sender {
    [self.Products authLoginName:@"" withPass:self.Products.userPwd];
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


-(void)closeBigPic:(UITapGestureRecognizer*)gestureRecognizer {
    gestureRecognizer.view.hidden = YES;
}

#pragma mark - Factory Delegates

-(void)loginDidFinish {
    self.statusLabel.text = self.Products.loginMessage;
    self.statusLabel.textColor = self.Products.loginMessageColor;
    [loginAct stopAnimating];
    if (![self.Products.loginMessage isEqualToString:@"Hibás jelszó!"]) {
        tableVersion = @"Menu";
        [self.tableViewCont reloadData];
        self.refreshButton.hidden = NO;
    }
}

-(void)collectionDidFinish {
    if ([self.Products.products count] != 0) {
        self.scrollView = [[BYProductImagesScrollView alloc] initWithFrame:CGRectMake(0.0f, 56.0f, self.view.bounds.size.width, self.view.bounds.size.height - 56.0f)];
        self.scrollView.delegate = self;
        self.back_button.hidden = NO;
        self.CategoryCont.hidden = NO;
        self.itemInfoCont.hidden = NO;
        self.CategoryName.text = menuName;
        if ([self.Products.basket count] > 0)[self.Products getBasketInfoFromDict:menuName];
        [self setStockInfoLabel:0];
        [self.scrollView addProductsToView:self.Products.products];
        [self.view insertSubview:self.scrollView belowSubview:self.CategoryCont];
    }
    [menuAct stopAnimating];
}

#pragma mark - UITextFieldDelegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.Products authLoginName:@"" withPass:textField.text];
    textField.text = @"";
    [loginAct startAnimating];
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - ByCellOrderPrototype Delegates

-(void)valueChanged:(int)itemId withNewValue:(int)newValue {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    BYCellPrototypeBasket *cell = (BYCellPrototypeBasket*)[self.tableViewCont cellForRowAtIndexPath:indexPath];
    BYOrder* tempOrder = [self.Products.actualOrderItems objectAtIndex:itemId];
    tempOrder.itemQuantityRel = newValue;
    cell.itemName.text = [NSString stringWithFormat:@"Összesen: %d db",[self.Products OrderItemSumm]];
}

-(void)orderStateChanged:(int)itemId withNewValue:(int)newValue {
    BYOrder* tempOrder = [self.Products.actualOrderItems objectAtIndex:itemId];
    tempOrder.state = newValue;
}

-(void)showImageInBig:(NSString *)imgURL {
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    self.itemBigPic.image = [[UIImage alloc] initWithData:imageData];
    self.itemBigPic.hidden = NO;
}

#pragma mark - ByCellBasketPrototype Delegates

-(void)valueChangedBasket:(NSString*)itemId withNewValue:(int)newValue {
    BYProduct *cellProduct = [self.Products.basket objectForKey:itemId];
    cellProduct.basket = newValue;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    BYCellPrototypeBasket *cell = (BYCellPrototypeBasket*)[self.tableViewCont cellForRowAtIndexPath:indexPath];
    cell.itemName.text = [NSString stringWithFormat:@"%@",[self.Products BasketItemsSumm]];
}

#pragma mark - ScrollView Delegates

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    [self setStockInfoLabel:pageNum];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    int pageNum = (int)(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    [self setStockInfoLabel:pageNum];
}

#pragma mark - TableView DataSource Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableVersion isEqualToString:@"Login"]) return 1;
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (self.Products.usrMode == 1) return 3;
        if (self.Products.usrMode == 2) return 2;
    }
    if ([tableVersion isEqualToString:@"Basket"]) return 2;
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableVersion isEqualToString:@"Login"]) return 2;
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (section == 1) return 1;
        if (self.Products.usrMode == 1) {
            if (section == 0) return [self.Products.menus count];
            if (section == 2) return 1;
        }
        if (self.Products.usrMode == 2 && section == 0) {
            NSLog(@"Count: %d",[self.Products.orders count]);
            if ([self.Products.orders count] == 0) {
                return 1;
            } else return [self.Products.orders count];
        }
    }
    if ([tableVersion isEqualToString:@"Basket"]) {
        if (self.Products.usrMode == 1) {
            if (section == 0) return [self.Products.basket count] + 1;
            if (section == 1) {
                if ([self.Products.basket count] == 0) {
                    return 1;
                } else {
                    return 2;
                }
            }
        }
        if (self.Products.usrMode == 2) {
            if (section == 0) return [self.Products.actualOrderItems count] + 1;
            if (section == 1) {
                if ([self.Products.actualOrderItems count] == 0) {
                    return 1;
                } else {
                    return 2;
                }
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
        if (indexPath.row == 1) {
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
            cell.aTextField.delegate = self;
            cell.label.text = @"Jelszó";
            cell.aTextField.secureTextEntry = YES;
            return cell;
        }
    }
    
    if ([tableVersion isEqualToString:@"Menu"]) {
        if (self.Products.usrMode == 1) {
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
        } else if (self.Products.usrMode == 2) {
            if (indexPath.section == 0) {
                if ([self.Products.orders count] != 0) {
                    NSArray *keys = [self.Products.orders allKeys];
                    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

                    static NSString *cellIdentifier = @"MenuCell";
                    BYCellPrototypeMenu *cell = (BYCellPrototypeMenu*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                                                  forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = [[BYCellPrototypeMenu alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    cell.menuName.text = [sortedKeys objectAtIndex:indexPath.row];
                    return cell;
                } else {
                    static NSString *cellIdentifier = @"SummCell";
                    BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    cell.itemName.text = @"Nincs élő rendelés a rendszerben";
                    return cell;
                }
            }
            if (indexPath.section == 1) {
                static NSString *cellIdentifier = @"SignOutCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                return cell;
            }
        }
    }
    
    if ([tableVersion isEqualToString:@"Basket"]) {
        if (self.Products.usrMode == 1) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    static NSString *cellIdentifier = @"SummCell";
                    BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    if ([self.Products.basket count] == 0) {
                        if (isPlaceOrder == 0) {
                            cell.itemName.text = @"Az Ön kosara üres";
                        } else {
                            cell.itemName.text = @"Rendelése sikeresen elküldve";
                            isPlaceOrder = 0;
                        }
                    } else {
                        cell.itemName.text = [NSString stringWithFormat:@"%@",[self.Products BasketItemsSumm]];
                    }
                    return cell;
                } else {
                    static NSString *cellIdentifier = @"ItemDetailsCell";
                    BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    cell.delegate = self;
                    BYProduct *cellProduct = [self.Products.basket objectForKey:[self.Products.allBasketKeys objectAtIndex:indexPath.row-1]];
                    cell.itemName.text = cellProduct.CategoryName;
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cellProduct.imageURL]];
                    cell.itemPic.image = [UIImage imageWithData:imageData];
                    cell.itemPieces.text = [NSString stringWithFormat:@"%d db",cellProduct.basket];
                    cell.itemNum = cellProduct.basket;
                    cell.maxItemNum = cellProduct.pieces + cellProduct.basket;
                    cell.itemNo.text = cellProduct.itemNo;
                    cell.oriItemPrice = cellProduct.itemPrice;
                    cell.oriItemSummPrice = cellProduct.itemPrice * cellProduct.basket;
                    cell.itemPrice.text = [NSString stringWithFormat:@"Egységár: %@ Ft",thousandSeparate(cell.oriItemPrice)];
                    cell.itemSummPrice.text = [NSString stringWithFormat:@"Érték: %@ Ft",thousandSeparate(cell.oriItemSummPrice)];
                    cell.productId = [self.Products.allBasketKeys objectAtIndex:indexPath.row-1];
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
        if (self.Products.usrMode == 2) {
            if (indexPath.section == 0) {
                if (indexPath.row == 0) {
                    static NSString *cellIdentifier = @"SummCell";
                    BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    if ([self.Products.actualOrderItems count] == 0) {
                        if (isPlaceOrder == 0) {
                            cell.itemName.text = @"A rendelés üres";
                        } else {
                            cell.itemName.text = @"Visszajelzés sikeresen elküldve";
                            isPlaceOrder = 0;
                        }
                    } else {
                        cell.itemName.text = [NSString stringWithFormat:@"Összesen: %d db",[self.Products OrderItemSumm]];
                    }
                    return cell;
                } else {
                    static NSString *cellIdentifier = @"OrderDetailsCell";
                    BYCellPrototypeOrder* orderSummCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    if (orderSummCell == nil) {
                        orderSummCell = (BYCellPrototypeOrder*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    orderSummCell.delegate = self;
                    BYOrder *cellProduct = (BYOrder*)[self.Products.actualOrderItems objectAtIndex:indexPath.row -1];
                    orderSummCell.itemName.text = cellProduct.itemCategory;
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:cellProduct.itemImg]];
                    orderSummCell.imgURL = cellProduct.itemImg;
                    orderSummCell.itemPic.image = [UIImage imageWithData:imageData];
                    orderSummCell.itemPieces.text = [NSString stringWithFormat:@"%d db",cellProduct.itemQuantity];
                    orderSummCell.itemPiecesChecked.text = [NSString stringWithFormat:@"%d db",cellProduct.itemQuantityRel];
                    orderSummCell.oriValue = cellProduct.itemQuantity;
                    orderSummCell.newValue = cellProduct.itemQuantityRel;
                    orderSummCell.itemNo.text = cellProduct.itemNo;
                    orderSummCell.orderId = indexPath.row - 1;
                    orderSummCell.state = cellProduct.state;
                    orderSummCell.itemPic.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:orderSummCell action:@selector(imageTapped:)];
                    [orderSummCell.itemPic addGestureRecognizer:tap];
                    
                    if (orderSummCell.state == 1) {
                        orderSummCell.backgroundColor = [UIColor greenColor];
                        orderSummCell.itemPic.userInteractionEnabled = NO;
                        orderSummCell.upButton.userInteractionEnabled = NO;
                        orderSummCell.downButton.userInteractionEnabled = NO;
                    } else {
                        orderSummCell.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1];
                        orderSummCell.upButton.userInteractionEnabled = YES;
                        orderSummCell.downButton.userInteractionEnabled = YES;
                        orderSummCell.itemPic.userInteractionEnabled = YES;
                    }
                    return orderSummCell;
                }
            }
            if (indexPath.section == 1 && [self.Products.actualOrderItems count] == 0) {
                static NSString *cellIdentifier = @"BackCell";
                BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                if (cell == nil) {
                    cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                return cell;
            } else {
                if (indexPath.row == 0) {
                    static NSString *cellIdentifier = @"SummCell";
                    BYCellPrototypeBasket *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    if (cell == nil) {
                        cell = (BYCellPrototypeBasket*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    cell.itemName.text = @"Csomag összeállítva";
                    cell.itemName.font = [UIFont systemFontOfSize:17.0];
                    cell.userInteractionEnabled = NO;
                    cell.itemName.textColor = [UIColor lightGrayColor];
                    [self checkOrderCollectedButtonState];
                    if (!orderCellState) {
                        cell.userInteractionEnabled = YES;
                        cell.itemName.textColor = [UIColor blackColor];
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
    }
    
    return nil;
}

#pragma mark - TableView Delegate Methods

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.Products.basket removeObjectForKey:[self.Products.allBasketKeys objectAtIndex:indexPath.row-1]];
        self.Products.allBasketKeys = [self.Products.basket allKeys];
        [self.tableViewCont reloadData];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableVersion isEqualToString:@"Basket"] && indexPath.section == 0 && indexPath.row != 0 && self.Products.usrMode == 1) {
        return YES;
    }
    return NO;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Törlés?";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableVersion isEqualToString:@"Login"]) {
        if (indexPath.row == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            BYCellPrototypeLogin *cellAuth = (BYCellPrototypeLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
            [self.Products authLoginName:@"" withPass:cellAuth.aTextField.text];
            cellAuth.aTextField.text = @"";
            [loginAct startAnimating];
            [self.view endEditing:YES];
        }
        return;
    }
    if ([tableVersion isEqualToString:@"Menu"]) {
        if ((indexPath.row == 0 && indexPath.section == 2 && self.Products.usrMode == 1) ||
            (indexPath.section == 1 && self.Products.usrMode == 2)) {
            tableVersion = @"Login";
            [self.tableViewCont reloadData];
            self.statusLabel.text = @"";
            self.refreshButton.hidden = YES;
        }
        if (indexPath.section == 0 &&
            ![[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"SummCell"]) {
            BYCellPrototypeMenu *clickedCell = (BYCellPrototypeMenu*)[tableView cellForRowAtIndexPath:indexPath];
            menuAct = clickedCell.menuItemsLoading;
            menuName = clickedCell.menuName.text;
            [menuAct startAnimating];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (self.Products.usrMode == 1) {
                [self.Products getMenuContents:indexPath.row];
            }
            if ([self.Products.orders count] != 0 && self.Products.usrMode == 2) {
                [self.Products getOrderContents:menuName];
                tableVersion = @"Basket";
                [self.tableViewCont reloadData];
            }
            self.refreshButton.hidden = YES;
        }
        if (indexPath.section == 1 && self.Products.usrMode == 1) {
            BYCellPrototypeMenu *clickedCell = (BYCellPrototypeMenu*)[tableView cellForRowAtIndexPath:indexPath];
            [clickedCell.menuItemsLoading startAnimating];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            tableVersion = @"Basket";
            [self.tableViewCont reloadData];
            [clickedCell.menuItemsLoading stopAnimating];
            self.refreshButton.hidden = YES;
        }
        return;
    }
    if ([tableVersion isEqualToString:@"Basket"]) {
        if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"OrderDetailsCell"]) {
            BYCellPrototypeOrder* tempCell = (BYCellPrototypeOrder*)[tableView cellForRowAtIndexPath:indexPath];
            tempCell.state ^= 1;
            if (tempCell.state == 1) {
                tempCell.backgroundColor = [UIColor greenColor];
                tempCell.itemPic.userInteractionEnabled = NO;
                tempCell.upButton.userInteractionEnabled = NO;
                tempCell.downButton.userInteractionEnabled = NO;
            } else {
                tempCell.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1];
                tempCell.upButton.userInteractionEnabled = YES;
                tempCell.downButton.userInteractionEnabled = YES;
                tempCell.itemPic.userInteractionEnabled = YES;
            }
            [tempCell.delegate orderStateChanged:indexPath.row-1 withNewValue:tempCell.state];
            [self checkOrderCollectedButtonState];
        }
        
        if (indexPath.row == 0 && indexPath.section == 1 && [self.Products.actualOrderItems count] != 0) {
            isPlaceOrder = 1;
            [self.Products collectedOrder];
            [self.tableViewCont reloadData];
            return;
        }
        if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"BackCell"]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            tableVersion = @"Menu";
            [self.tableViewCont reloadData];
            self.refreshButton.hidden = NO;
        }
        if ([[[tableView cellForRowAtIndexPath:indexPath] reuseIdentifier] isEqualToString:@"PlaceOrderCell"]) {
            isPlaceOrder = 1;
            [self.Products PlaceOrder];
            [self.tableViewCont reloadData];
        }
        return;
    }
}


@end
