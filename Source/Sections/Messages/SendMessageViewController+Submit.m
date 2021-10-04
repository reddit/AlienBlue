//
//  SendMessageViewController+Submit.m
//  AlienBlue
//
//  Created by J M on 27/04/12.
//  Copyright (c) 2012 The Design Shed. All rights reserved.
//

#import "SendMessageViewController+Submit.h"
#import "NavigationManager.h"
#import "MBProgressHUD.h"
#import "RedditAPI+Messages.h"

@interface SendMessageViewController (Submit_)
@property (strong) NSString *captchaID;
@property (strong) NSString *captchaEntered;
@end

@implementation SendMessageViewController (Submit)

SYNTHESIZE_ASSOCIATED_STRONG(NSString, captchaID, CaptchaID);
SYNTHESIZE_ASSOCIATED_STRONG(NSString, captchaEntered, CaptchaEntered);

- (void)showCaptchaEntry;
{
    CaptchaEntryViewController *captchaViewController = [[CaptchaEntryViewController alloc] initWithDelegate:self propertyKey:@"captcha"];
    [self.navigationController pushViewController:captchaViewController animated:YES];
}

- (void)didEnterCaptcha:(NSString *)captchaEntered forCaptchaId:(NSString *)captchaId;
{
    self.captchaID = captchaId;
    self.captchaEntered = captchaEntered;
    [self performSelector:@selector(submit) withObject:nil afterDelay:1.];
}

- (void)submitResponse:(id)sender
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSMutableArray * errors = (NSMutableArray *) sender;
    
    if (errors && [errors count] == 0)
    {
        [PromptManager addPrompt:@"Your message has been delivered."];
        [[NavigationManager shared] dismissModalView];
    }
    else if (errors && [errors count] > 0)
    {
        BOOL captchaError = NO;
        NSMutableString * errorMessage = [NSMutableString stringWithString:@"reddit has reported the following information:\n\n"];

        for (NSString * error in errors)
        {
            if ([error contains:@"captcha"])
            {
                captchaError = YES;
            }
            [errorMessage appendFormat:@"* %@\n", error];
        }

        if ([errors count] == 1 && captchaError)
        {
            [self showCaptchaEntry];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)submit;
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:@"Sending message"];
    
    NSString *subj = self.subject;
    NSString *content = self.messageTextView.text;
    NSString *uname = self.username;
    
    SET_IF_EMPTY(subj, @"");
    SET_IF_EMPTY(content, @"");
    SET_IF_EMPTY(uname, @"");
    
    NSMutableDictionary * newPM = [[NSMutableDictionary alloc] init]; 
    [newPM setValue:content forKey:@"content"];
    [newPM setValue:subj forKey:@"subject"];
    [newPM setValue:self.captchaID forKey:@"captchaID"];
    [newPM setValue:self.captchaEntered forKey:@"captchaEntered"];
    [newPM setValue:uname forKey:@"toUsername"];
    [[RedditAPI shared] submitDirectMessage:newPM withCallBackTarget:self];
}

@end
