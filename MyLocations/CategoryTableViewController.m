//
//  CategoryTableViewController.m
//  MyLocations
//
//  Created by zhu yongxuan on 15/8/18.
//  Copyright (c) 2015年 zhu yongxuan. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "LocationDetailViewController.h"

@interface CategoryTableViewController ()

@end

@implementation CategoryTableViewController
{
    NSArray *_categorys;
    NSIndexPath *_selectedInPath;
}



#pragma mark - Life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _categorys = @[
                   @"No Category",
                   @"Apple Store",
                   @"Bar",
                   @"Bookstore",
                   @"Club",
                   @"Grocery Store",
                   @"Historic Building",
                   @"House",
                   @"Icecream Vendor",
                   @"Landmark",
                   @"Park"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickedCategory"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        self.selectedCategoryName = _categorys[indexPath.row];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_categorys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSString *categoryName = _categorys[indexPath.row];
    cell.textLabel.text = categoryName;
    
    if ([categoryName isEqualToString:self.selectedCategoryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark; // 如果是选中的单元，单元打钩标记
        _selectedInPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 判断是否新选中单元，新选中单元，将新单元标记，取消旧选中单元的标记
    if (indexPath.row != _selectedInPath.row) {
        //将
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_selectedInPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        _selectedInPath = indexPath;
    } 
    
}


@end
