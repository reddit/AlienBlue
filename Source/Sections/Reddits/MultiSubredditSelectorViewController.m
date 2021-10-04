//
//  MultiSubredditSelectorViewController.m
//  AlienBlue
//
//  Created by J M on 4/06/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "MultiSubredditSelectorViewController.h"
#import "NSubredditCell.h"
#import "Resources.h"

typedef void (^MultiSubredditSelectorOnCompleteAction)(NSArray *subreddits);

@interface MultiSubredditSelectorViewController ()
- (void)generateNodes;
@property (strong) SubredditFolder *sourceFolder;
@property (copy) MultiSubredditSelectorOnCompleteAction onComplete;
@end

@implementation MultiSubredditSelectorViewController

- (id)initWithSourceFolder:(SubredditFolder *)folder onComplete:(void (^)(NSArray *subreddits))onComplete;
{
    self = [super init];
    if (self)
    {
        self.sourceFolder = folder;
        self.onComplete = onComplete;
        [self setNavbarTitle:@"Choose Subreddit(s)"];
    }
    return self;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    [self generateNodes];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // override JMOutlineViewControllers attempts to deselect other nodes
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
    UIColor *highlightColor = [Resources isNight] ? [UIColor colorWithWhite:1. alpha:0.04] : [UIColor colorWithWhite:0. alpha:0.04];
    selectedView.backgroundColor = highlightColor;
    cell.selectedBackgroundView = selectedView;
    return cell;
}

- (void)viewWillDisappear:(BOOL)animated;
{
    BSELF(MultiSubredditSelectorViewController);
    NSArray *selectedSubreddits = [[self.tableView indexPathsForSelectedRows] map:^id(NSIndexPath *ip) {
        return [blockSelf.sourceFolder.subreddits objectAtIndex:ip.row];
    }];
    if (self.onComplete)
    {
        self.onComplete(selectedSubreddits);
    }
    [super viewWillDisappear:animated];
}

- (void)generateNodes;
{
    [self removeAllNodes];
    
    NSArray *subredditNodes = [self.sourceFolder.subreddits map:^id(Subreddit *obj) {
        return [SubredditNode nodeForSubreddit:obj];
    }];
    [self addNodes:subredditNodes];
    [self reload];
}

@end
