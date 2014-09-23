//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"


@implementation JSQMessagesToolbarButtonFactory

+ (UIButton *)defaultAccessoryButtonItem
{
    UIImage *cameraImage = [UIImage imageNamed:@"camera"];
    UIImage *cameraNormal = [cameraImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *cameraHighlighted = [cameraImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [cameraButton setImage:cameraNormal forState:UIControlStateNormal];
    [cameraButton setImage:cameraHighlighted forState:UIControlStateHighlighted];
    
    cameraButton.contentMode = UIViewContentModeScaleAspectFit;
    cameraButton.backgroundColor = [UIColor clearColor];
    cameraButton.tintColor = [UIColor colorWithRed:183/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f];
    
    return cameraButton;
}

+ (UIButton *)defaultSendButtonItem
{
    NSString *sendTitle = NSLocalizedString(@"Send", @"Text for the send button on the messages view toolbar");



    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:89/255.0f green:186/255.0f blue:209/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [sendButton setTitleColor:[[UIColor colorWithRed:89/255.0f green:186/255.0f blue:209/255.0f alpha:1.0f] jsq_colorByDarkeningColorWithValue:0.1f] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor colorWithRed:183/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f] forState:UIControlStateDisabled];

    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor jsq_messageBubbleBlueColor];
    
    return sendButton;
}

@end
