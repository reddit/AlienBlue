#import "ABOutlineViewController.h"

@class SubredditNode;
@class SubredditFolderNode;
@class SectionTitleNode;
@class SectionSpacerNode;
@class OptionNode;

@interface RedditsViewController : ABOutlineViewController
- (SectionSpacerNode *)addSpacerNode;
- (SectionTitleNode *)addSectionTitleNodeWithTitle:(NSString *)title;
- (SubredditNode *)addCustomSubredditNodeWithTitle:(NSString *)title url:(NSString *)url;
- (OptionNode *)addOptionNodeWithTitle:(NSString *)title icon:(UIImage *)icon onTap:(ABAction)onTap onSecondary:(ABAction)onSecondary;
- (OptionNode *)addOptionNodeWithTitle:(NSString *)title icon:(UIImage *)icon;
- (void)toggleSubredditFolderCollapseForNode:(SubredditFolderNode *)folderNode;
- (void)animateNodeChanges;
- (void)generateNodes;

- (void)sortFoldersAlphabetically;
- (void)showFolderManagementView;

- (void)showPostsForSubreddit:(NSString *)sr withTitle:(NSString *)title;
@end
