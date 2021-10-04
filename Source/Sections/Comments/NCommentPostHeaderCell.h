//
//  NCommentPostHeaderCell.h
//  AlienBlue
//
//  Created by J M on 19/12/11.
//  Copyright (c) 2011 The Design Shed. All rights reserved.
//

#import "NBaseStyledTextCell.h"
#import "PostImagePreviewOverlay.h"
#import "CommentPostHeaderThumbnailOverlay.h"
#import "FaviconOverlay.h"


@class CommentPostHeaderToolbar;

@interface NCommentPostHeaderCell : NBaseStyledTextCell
@property (strong, readonly) CommentPostHeaderThumbnailOverlay *thumbOverlay;
@property (strong, readonly) JMViewOverlay *titleTextOverlay;
@property (strong, readonly) JMViewOverlay *titleBackgroundOverlay;
@property (strong, readonly) JMViewOverlay *subdetailsBar;
@property (strong, readonly) FaviconOverlay *faviconOverlay;
@property (strong, readonly) PostImagePreviewOverlay *imagePreviewOverlay;
@property (readonly) Post *post;
@property (readonly) CGFloat recommendedTitleMargin;


// override for customisation
+ (CGFloat)subdetailsBarHeight;
+ (CGFloat)subdetailsBarBottomMargin;
+ (CGFloat)titleMarginWithThumbnail;
+ (CGFloat)titleMarginWithoutThumbnail;
+ (CGFloat)minimumHeightWithThumbnail;

@end
