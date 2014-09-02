//
//  JSQMessagesMedia.m
//  JSQMessages
//
//  Created by Pierluigi Cifani on 17/6/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSQMessagesMediaHandler.h"
#import "JSQMessagesCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface JSQMessagesMediaHandler ()

@property (nonatomic, weak) JSQMessagesCollectionViewCell *cell;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic) SEL updateSelector;
@end

@implementation JSQMessagesMediaHandler

+ (instancetype)mediaHandlerWithCell:(id)cell
{
    JSQMessagesMediaHandler *instance = [self new];
    instance.cell = cell;

    return instance;
}

-(void)setCell:(JSQMessagesCollectionViewCell *)cell
{
    _cell = cell;

    cell.mediaImageView.contentMode = UIViewContentModeCenter;
    cell.mediaImageView.backgroundColor = [UIColor colorWithRed:0.925 green:0.925 blue:0.925 alpha:1] /*#ececec*/;
    cell.mediaImageView.clipsToBounds = YES;
}

- (void) setMediaFromImage:(UIImage *)image;
{
    self.cell.mediaImageView.image = image;
    [self maskImageViewWithBubble];
}

- (void) setMediaFromURL:(NSURL *)imageURL;
{
    [self addActitityIndicator];

    __weak __typeof(self) weakSelf = self;

    [self.cell.mediaImageView setImageWithURL:imageURL
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

                                        __typeof(self) strongSelf = weakSelf;
                                        [strongSelf maskImageViewWithBubble];
                                        [strongSelf removeActitityIndicator];
                                    }];
}

- (void) cellWillBeReused;
{
    self.cell.mediaImageView.image = nil;
    [self.cell.mediaImageView cancelCurrentImageLoad];
    [self removeActitityIndicator];
    self.expirationDate = nil;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark Private

- (void) maskImageViewWithBubble
{
    /**
     *  For the next snippet of code to work, the mediaImageView's frame
     *  must be the same as the messageBubbleImageView's frame
     */
    [self.cell.mediaImageView removeConstraints:self.cell.mediaImageView.constraints];
    [self.cell layoutIfNeeded];
    [self.cell.mediaImageView setFrame:self.cell.messageBubbleImageView.frame];

    /**
     *  Snippet from https://github.com/SocialObjects-Software/SOMessaging
     */
    CALayer *layer = self.cell.messageBubbleImageView.layer;
    layer.frame = (CGRect){{0,0},self.cell.messageBubbleImageView.layer.frame.size};
    self.cell.mediaImageView.layer.mask = layer;
    [self.cell.mediaImageView setNeedsDisplay];
}

- (void) addActitityIndicator
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.cell.messageBubbleImageView addSubview:activityIndicator];

    /**
     *  Center in superview
     */
    UIView *superview = self.cell.messageBubbleImageView;
    NSDictionary *variables = NSDictionaryOfVariableBindings(activityIndicator, superview);
    NSArray *constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[activityIndicator]"
                                            options: NSLayoutFormatAlignAllCenterX
                                            metrics:nil
                                              views:variables];
    [self.cell.contentView addConstraints:constraints];

    constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:[superview]-(<=1)-[activityIndicator]"
                                            options: NSLayoutFormatAlignAllCenterY
                                            metrics:nil
                                              views:variables];
    [self.cell.contentView addConstraints:constraints];

    [activityIndicator startAnimating];

    self.activityIndicator = activityIndicator;
}

- (void) removeActitityIndicator
{
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
}

- (void)manageUpdates {
    if (self.expirationDate) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(metaUpdate)];
        self.displayLink.frameInterval = 60;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)metaUpdate{
    [self updateTimer];
    if(self.updateSelector) {
        [self performSelector:self.updateSelector];
    }
}

- (void)drawNewLabel{
    self.cell.cellBottomLabel.text = self.expirationString;
}

- (void) killLabelUpdates{
    self.didFinishCountingDownHandler();
    [self.displayLink invalidate];
    [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink = nil;
        if (self.refreshDelegate) {
        [self.refreshDelegate didExpire];
    }
}
- (void)updateTimer {
    if (self.hasExpired) {
        self.updateSelector = @selector(killLabelUpdates);
    } else {
        self.updateSelector = @selector(drawNewLabel);
    }
}

- (BOOL)hasExpired {
    return [self.expirationDate timeIntervalSinceDate:[NSDate date]] <= 0;
}

- (NSString *)expirationString {
    return self.remainingTimeString;
}


- (NSString *)remainingTimeString {
    int seconds = self.remainingTimeInterval;

    int hours = floor(seconds /  (60 * 60) );

    float minute_divisor = seconds % (60 * 60);
    int minutes = floor(minute_divisor / 60);

    float seconds_divisor = seconds % 60;
    seconds = ceil(seconds_divisor);

    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds ];
}


- (int)remainingTimeInterval {
    return (int) [self.expirationDate timeIntervalSinceDate:[NSDate date]];
}

@end
