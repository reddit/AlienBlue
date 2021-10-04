#import "TemplateGroup+SampleTemplates.h"

#define ADD_SAMPLE(IS_COMMENT, TITLE, BODY) [self appendSampleWithTitle:TITLE body:BODY isComment:IS_COMMENT];

@implementation TemplateGroup (SampleTemplates)

- (void)appendSampleWithTitle:(NSString *)title body:(NSString *)body isComment:(BOOL)isComment;
{
  Template *t = [Template templateWithTitle:title body:body];
  t.sendPreference = (isComment) ? TemplateSendPreferenceComment : TemplateSendPreferencePersonalMessage;
  t.stockTemplate = YES;
  [self i_addTemplate:t];
}

- (void)addApprovalSampleTemplates;
{
  ADD_SAMPLE(NO, @"Post retrieved from spam", @"Hi <poster_username>,\n\nIt looks like your [post](<post_url>) was trapped in the spam filter. I've approved it now, so it should be visible to other users.\n\nRegards,\n\n<moderator_username>");
  ADD_SAMPLE(NO, @"Caution for promotional post", @"Hi <poster_username>,\n\nAlthough I've approved your recent [post](<post_url>), please be mindful that frequently posting links to a personal website (or YouTube channel) can result in aggressive spam filtering and/or a ban. That said, posting links to personal content now and again is encouraged.\n\nRegards,\n\n<moderator_username>");
}

- (void)addRemovalSampleTemplates;
{
  ADD_SAMPLE(YES, @"No memes/rage comics allowed", @"This subreddit doesn't allow the submission of memes or rage comics. Please refer to the sidebar for guidelines.");
  ADD_SAMPLE(YES, @"Post is off-topic", @"This post is off topic for <subreddit_link>. Please refer to the sidebar for more information.");
  ADD_SAMPLE(YES, @"Linking to blogspam", @"This post links to blogspam (an article that recycles content from another source). When possible, please post links to the original article/source.");
  ADD_SAMPLE(YES, @"Offensive content", @"Links to offensive material are not allowed in this subreddit. Please refer to the sidebar for more information.");
  ADD_SAMPLE(YES, @"Personal information (dox)", @"This post was removed as it promotes sensitive personal identification and contact information of another individual.");
}

@end
