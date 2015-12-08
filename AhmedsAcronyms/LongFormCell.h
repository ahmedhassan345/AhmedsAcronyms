//
//  LongFormCell.h
//  AhmedsAcronyms
//
//  Created by Ahmed H on 12/7/15.
//  Copyright © 2015 Ahmed H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongFormCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *popBar;
@property (weak, nonatomic) IBOutlet UILabel *inUseSinceLabel;

@end
