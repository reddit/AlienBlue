//
//  JMTextFieldEntryCell.m
//  AlienBlue
//
//  Created by J M on 11/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "JMTextFieldEntryCell.h"
#import "JMTextFieldEntry.h"
#import "JMOutlineViewController+Keyboard.h"
#import "Resources.h"

@interface JMTextFieldEntryNode()
@property (copy) JMTextFieldEntryNodeCompleteAction onComplete;
@end

@implementation JMTextFieldEntryNode

- (id)init
{
  JM_SUPER_INIT(init);
  self.autoCorrectionType = UITextAutocorrectionTypeDefault;
  return self;
}

+ (JMTextFieldEntryNode *)textEntryNodeOnComplete:(JMTextFieldEntryNodeCompleteAction)onComplete;
{
    JMTextFieldEntryNode *node = [[JMTextFieldEntryNode alloc] init];
    node.onComplete = onComplete;
    return node;
}

+ (Class)cellClass;
{
    return NSClassFromString(@"JMTextFieldEntryCell");
}

@end

@interface JMTextFieldEntryCell() <JMTextFieldEntryDelegate>
@property (strong) JMTextFieldEntry *entryView;
@property (copy) JMTextFieldEntryNodeCompleteAction onComplete;
@property (copy) JMTextFieldEntryNodeCompleteAction onEndEditing;
@property (copy) ABAction onCancel;
@end

@implementation JMTextFieldEntryCell

+ (CGFloat)heightForNode:(JMOutlineNode *)node tableView:(UITableView *)tableView;
{
    return 48.;
}

- (void)createSubviews;
{
    self.containerView.backgroundColor = [UIColor colorForBackground];
    
    self.entryView = [[JMTextFieldEntry alloc] init];
    self.entryView.frame = self.containerView.bounds;
    self.entryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.entryView.delegate = self;
    
    [self.containerView addSubview:self.entryView];
}

- (void)updateWithNode:(JMOutlineNode *)node;
{
    [super updateWithNode:node];
    JMTextFieldEntryNode *entryNode = (JMTextFieldEntryNode *)node;
    [self.entryView setTextFieldPlaceholder:entryNode.placeholder];
    [self.entryView setDefaultText:entryNode.defaultText];
    [self.entryView setAutocapitalizationType:entryNode.capitalizationType];
    self.entryView.textField.autocorrectionType = entryNode.autoCorrectionType;
    self.entryView.textField.keyboardAppearance = [Resources isNight] ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;

    self.onComplete = entryNode.onComplete;
    self.onCancel = entryNode.onCancel;
    self.onEndEditing = entryNode.onEndEditing;

    if (entryNode.textColor)
    {
        self.entryView.textField.textColor = entryNode.textColor;
    }
    
    if (entryNode.backgroundColor)
    {
        self.entryView.textField.backgroundColor = entryNode.backgroundColor;
    }
}

- (void)textFieldEntry:(JMTextFieldEntry *)textFieldEntry finishedWithString:(NSString *)string;
{
    [self.entryView cancel];
    self.onComplete(string);
}

- (void)textFieldEntryDidCancel:(JMTextFieldEntry *)textFieldEntry;
{
    if (self.onCancel)
    {
        self.onCancel();
    }
}

- (void)textFieldEntryDidEndEditing:(JMTextFieldEntry *)textFieldEntry;
{
    if (self.onEndEditing)
    {
        self.onEndEditing(textFieldEntry.textField.text);
    }
}

@end
