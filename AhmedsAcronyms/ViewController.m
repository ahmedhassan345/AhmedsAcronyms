//
//  ViewController.m
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import "ViewController.h"
#import "LongFormCell.h"
#import "acronym.h"
#import "AcromineAPIWorker.h"
#import "MBProgressHUD.h"

@interface ViewController ()
- (IBAction)sortBtnAction:(UIBarButtonItem *)sender;

@end

@implementation ViewController
{
    NSArray* acronyms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Search Bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    acronyms = nil;
    [self.tableView reloadData];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    hud.dimBackground = YES;
    [[AcromineAPIWorker sharedWorker] getLongFormsForAcronym:searchBar.text WithResponseHandler:^(NSArray *retrievedAcronyms, NSString *errorString)
    {
        if (!errorString)
        {
            if ([retrievedAcronyms count])
            {
                acronyms = retrievedAcronyms;
                [self.tableView reloadData];
                
                [hud hide:YES];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"No long forms found for this acronym.";
                hud.margin = 10.f;
                
                [hud hide:YES afterDelay:3];
            }
        }
        else
        {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = errorString;
            hud.margin = 10.f;
            
            [hud hide:YES afterDelay:3];
        }
    }];
}

#pragma mark Table View Delegate and Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [acronyms count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [((acronym*)acronyms[section]).longForms count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ((acronym*)acronyms[section]).name;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LongFormCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LongFormCell"];
    acronym* currentAcronym = acronyms[indexPath.section];
    longForm* currentLongForm = currentAcronym.longForms[indexPath.row];
    
    cell.nameLabel.text = currentLongForm.name;
    cell.inUseSinceLabel.text = [NSString stringWithFormat:@"%li",(long)currentLongForm.usedSince];
    cell.popBar.progress = currentAcronym.mostUsedLF? (float)currentLongForm.usageFreq/currentAcronym.mostUsedLF:0.0;
    
    if (cell.popBar.progress < 0.33)
    {
        cell.popBar.progressTintColor = [UIColor redColor];
    }
    else if (cell.popBar.progress < 0.67)
    {
        cell.popBar.progressTintColor = [UIColor orangeColor];
    }
    else
    {
        cell.popBar.progressTintColor = [UIColor greenColor];
    }
    
    return cell;
}

#pragma mark Button Actions

- (IBAction)sortBtnAction:(UIBarButtonItem *)sender
{
    if (self.presentedViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIAlertController* actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    void (^sortActionHandler)(UIAlertAction* action) = ^(UIAlertAction * action)
    {
        if (action.style == UIAlertActionStyleCancel) return;
        
        NSArray* theSortDescriptors;
        
        if ([action.title isEqualToString:@"Alphabetically"])
        {
            theSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        }
        else if ([action.title isEqualToString:@"by Popularity"])
        {
            theSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"usageFreq" ascending:NO]];
        }
        else if ([action.title isEqualToString:@"by Date"])
        {
            theSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"usedSince" ascending:YES]];
        }
        
        for (acronym* anAcronym in acronyms)
        {
            anAcronym.longForms = [anAcronym.longForms sortedArrayUsingDescriptors:theSortDescriptors];
        }
        
        [self.tableView reloadData];
    };
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"Alphabetically" style:UIAlertActionStyleDefault handler:sortActionHandler]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"by Popularity" style:UIAlertActionStyleDefault handler:sortActionHandler]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"by Date" style:UIAlertActionStyleDefault handler:sortActionHandler]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:sortActionHandler]];
    
    [actionSheetController setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [actionSheetController
                                                     popoverPresentationController];
    popPresenter.barButtonItem = sender;
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

@end
