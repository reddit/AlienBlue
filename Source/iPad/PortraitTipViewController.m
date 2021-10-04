//
//  PortraitTipViewController.m
//  AlienBlue
//
//  Created by J M on 4/03/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "PortraitTipViewController.h"
#import "OverlayViewContainer.h"
#import "Resources.h"
#import "NavigationManager_iPad.h"
#import "SidePane_iPad.h"

#define kTipTextColor [UIColor colorWithHex:0x868686]
#define kTipButtonBGColorSelected [UIColor colorWithHex:0x868686]
#define kTipButtonBGColorNormal [UIColor colorWithHex:0xC6C6C6]

#define kTipButtonBGColorDismiss [UIColor colorWithHex:0x3c7e53]
#define kTipButtonBGColorDismissHighlighted [UIColor colorWithHex:0x215232]

@interface PortraitTipViewController()
@property (strong) OverlayViewContainer *container;
@property (strong) JMViewOverlay *standardButton;
@property (strong) JMViewOverlay *compactButton;
- (void)toggleCompactMode;
- (void)toggleStandardMode;
- (void)updateButtons;
- (void)dismissReminder;
@end

@implementation PortraitTipViewController

- (void)loadView;
{
    [super loadView];
    
    BSELF(PortraitTipViewController);
    
    self.container = [[OverlayViewContainer alloc] initWithFrame:self.view.bounds];
    self.container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.container];
    
    JMViewOverlay *gradient = [JMViewOverlay overlayWithFrame:self.container.bounds drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView drawGradientInRect:bounds minHeight:0. startColor:[UIColor colorWithHex:0xebebeb] endColor:[UIColor colorWithHex:0xcccccc]];
    }];
    gradient.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.container addOverlay:gradient];

    JMViewOverlay *titleOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(0., 22., self.container.width, 22.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [UIView startEtchedDraw];
        [kTipTextColor set];
        [@"Portrait Browsing" drawInRect:bounds withFont:[UIFont skinFontWithName:kBundleFontTipTitle] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        [UIView endEtchedDraw];
    }];
    titleOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.container addOverlay:titleOverlay];
    
    JMViewOverlay *instructionsOverlay = [JMViewOverlay overlayWithFrame:CGRectMake(100., titleOverlay.bottom + 22., self.container.width - 200., 70.) drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        NSString *instructions = @"When browsing in Portrait, Alien Blue offers you two different layouts. You can explore a layout that feels most comfortable for you.";
        [UIView startEtchedDraw];
        [kTipTextColor set];
        [instructions drawInRect:bounds withFont:[UIFont skinFontWithName:kBundleFontTipBody] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        [UIView endEtchedDraw];
    }];
    instructionsOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;    
    [self.container addOverlay:instructionsOverlay];
    
    CGRect standardFrame = CGRectMake(48., instructionsOverlay.bottom + 4., 116., 138.);
    JMViewOverlay *standardLayoutOverlay = [JMViewOverlay overlayWithFrame:standardFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        UIImage *img = [UIImage skinImageNamed:@"tips/tip-portrait-standard"];
        CGFloat opacity = highlighted ? 0.6 : 1.;
        [UIView startEtchedDraw];
        [img drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:opacity];
        [UIView endEtchedDraw];
    } onTap:^(CGPoint touchPoint){
        [blockSelf toggleStandardMode];
    }];
    standardLayoutOverlay.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.container addOverlay:standardLayoutOverlay];
        
    CGRect compactFrame = CGRectOffset(standardFrame, standardFrame.size.width + 46., 0.);
    JMViewOverlay *compactLayoutOverlay = [JMViewOverlay overlayWithFrame:compactFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        UIImage *img = [UIImage skinImageNamed:@"tips/tip-portrait-compact"];
        CGFloat opacity = highlighted ? 0.6 : 1.;
        [UIView startEtchedDraw];
        [img drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:opacity];
        [UIView endEtchedDraw];
    } onTap:^(CGPoint touchPoint){
        [blockSelf toggleCompactMode];
    }];
    [self.container addOverlay:compactLayoutOverlay];
    
    standardFrame.origin.y = standardLayoutOverlay.bottom + 20.;
    standardFrame.size.height = 30.;
    
    self.standardButton = [JMViewOverlay overlayWithFrame:standardFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        CGRect buttonRect = CGRectInset(bounds, 1., 1.);
        UIColor *bgColor = (selected || highlighted) ? kTipButtonBGColorSelected : kTipButtonBGColorNormal;
        [bgColor set];
        [UIView startEtchedDraw];
        [[UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:4.] fill];
        [UIView endEtchedDraw];
        [[UIColor whiteColor] set];
        CGRect titleRect = CGRectOffset(buttonRect, 0., 6.);
        [@"Wide" drawInRect:titleRect withFont:[UIFont boldSystemFontOfSize:13.] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    } onTap:^(CGPoint touchPoint) {
        [blockSelf toggleStandardMode];
    }];
    [self.container addOverlay:self.standardButton];

    compactFrame.origin.y = compactLayoutOverlay.bottom + 20.;
    compactFrame.size.height = 30.;
    
    self.compactButton = [JMViewOverlay overlayWithFrame:compactFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        CGRect buttonRect = CGRectInset(bounds, 1., 1.);
        UIColor *bgColor = (selected || highlighted) ? kTipButtonBGColorSelected : kTipButtonBGColorNormal;
        [bgColor set];
        [UIView startEtchedDraw];
        [[UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:4.] fill];
        [UIView endEtchedDraw];
        [[UIColor whiteColor] set];
        CGRect titleRect = CGRectOffset(buttonRect, 0., 6.);
        [@"Compact" drawInRect:titleRect withFont:[UIFont boldSystemFontOfSize:13.] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    } onTap:^(CGPoint touchPoint) {
        [blockSelf toggleCompactMode];
    }];
    [self.container addOverlay:self.compactButton];
  
    CGRect subtitleFrame = instructionsOverlay.frame;
    subtitleFrame.origin.y = self.compactButton.bottom + 15.;
    subtitleFrame.size.height = 40;
    JMViewOverlay *subtitleOverlay = [JMViewOverlay overlayWithFrame:subtitleFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        [kTipTextColor set];
        [UIView startEtchedDraw];
        [@"You can change this in the Settings pane at any time." drawInRect:bounds withFont:[UIFont skinFontWithName:kBundleFontTipBody] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        [UIView endEtchedDraw];
    }];
    subtitleOverlay.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;    
    [self.container addOverlay:subtitleOverlay];
    
    CGRect dismissFrame = CGRectMake(self.standardButton.left, subtitleOverlay.bottom + 10., self.compactButton.right - self.standardButton.left, 30.);
    JMViewOverlay *dismissButton = [JMViewOverlay overlayWithFrame:dismissFrame drawBlock:^(BOOL highlighted, BOOL selected, CGRect bounds) {
        CGRect buttonRect = CGRectInset(bounds, 1., 1.);
        UIColor *bgColor = (selected || highlighted) ? kTipButtonBGColorDismissHighlighted : kTipButtonBGColorDismiss;
        [bgColor set];
        [UIView startEtchedDraw];
        [[UIBezierPath bezierPathWithRoundedRect:buttonRect cornerRadius:4.] fill];
        [UIView endEtchedDraw];
        [[UIColor whiteColor] set];
        CGRect titleRect = CGRectOffset(buttonRect, 0., 6.);
        [@"Don't remind me again." drawInRect:titleRect withFont:[UIFont boldSystemFontOfSize:13.] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    } onTap:^(CGPoint touchPoint) {
        [blockSelf dismissReminder];
    }];
    [self.container addOverlay:dismissButton];
    
    [self updateButtons];
}

- (void)updateButtons;
{
    self.compactButton.selected = [Resources compactPortrait];
    self.standardButton.selected = ![Resources compactPortrait];
}

- (void)toggleCompactMode;
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kABSettingKeyIpadCompactPortrait];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateButtons];

    [[NavigationManager_iPad foldingNavigation] layoutControllers];
    [[NavigationManager_iPad foldingNavigation] performSelector:@selector(scrollToController:) withObject:[NavigationManager_iPad foldingNavigation].topViewController afterDelay:0.5];
}

- (void)toggleStandardMode;
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kABSettingKeyIpadCompactPortrait];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateButtons];
    
    [[NavigationManager_iPad foldingNavigation] layoutControllers];
    [[NavigationManager_iPad foldingNavigation] performSelector:@selector(scrollToController:) withObject:[NavigationManager_iPad foldingNavigation].topViewController afterDelay:0.5];
}

- (void)dismissReminder;
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kABSettingKeyIpadCompactPortraitTrainingComplete];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSidePaneNeedsRefreshNotification object:nil];
    [[NavigationManager_iPad shared] dismissPopoverIfNecessary];
}

- (CGSize)contentSizeForViewInPopover;
{
    return CGSizeMake(370., 446.);
}

- (CGSize)preferredContentSize;
{
  return self.contentSizeForViewInPopover;
}

+ (PortraitTipViewController *)controller;
{
    return [[[self class] alloc] initWithNibName:nil bundle:nil];
}

@end
