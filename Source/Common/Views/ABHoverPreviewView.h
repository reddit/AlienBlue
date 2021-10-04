@interface ABHoverPreviewView : UIView
+ (BOOL)canShowPreviewForURL:(NSURL *)URL;
+ (void)showPreviewForURL:(NSURL *)URL fromRect:(CGRect)rect onSuccessfulPresentation:(JMAction)onSuccessfulPresentation;
+ (BOOL)isShowingPreview;
+ (BOOL)hasRecentlyDismissedPreview;
+ (void)cancelVisiblePreviewAnimated:(BOOL)animated;
@end
