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
@property (weak, nonatomic) IBOutlet UITableView *theTableView;

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

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    acronyms = nil;
    [self.theTableView reloadData];
    [searchBar resignFirstResponder];
    
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
                [self.theTableView reloadData];
                
                [hud hide:YES];
            }
            else
            {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = NSLocalizedString(@"No long forms found for this acronym.", @"");
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
        
        if ([action.title isEqualToString:NSLocalizedString(@"Alphabetically", @"")])
        {
            theSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        }
        else if ([action.title isEqualToString:NSLocalizedString(@"by Popularity", @"")])
        {
            theSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"usageFreq" ascending:NO]];
        }
        else if ([action.title isEqualToString:NSLocalizedString(@"by Date", @"")])
        {
            theSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"usedSince" ascending:YES]];
        }
        
        for (acronym* anAcronym in acronyms)
        {
            anAcronym.longForms = [anAcronym.longForms sortedArrayUsingDescriptors:theSortDescriptors];
        }
        
        [self.theTableView reloadData];
    };
    [actionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Alphabetically", @"") style:UIAlertActionStyleDefault handler:sortActionHandler]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"by Popularity", @"") style:UIAlertActionStyleDefault handler:sortActionHandler]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"by Date", @"") style:UIAlertActionStyleDefault handler:sortActionHandler]];
    [actionSheetController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:sortActionHandler]];
    
    [actionSheetController setModalPresentationStyle:UIModalPresentationPopover];
    UIPopoverPresentationController *popPresenter = [actionSheetController
                                                     popoverPresentationController];
    popPresenter.barButtonItem = sender;
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

@end
