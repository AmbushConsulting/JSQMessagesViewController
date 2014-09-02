//
//  JSQMessagesMedia.h
//  JSQMessages
//
//  Created by Pierluigi Cifani on 17/6/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessageData.h"

@class JSQMessagesCollectionViewCell;

@protocol MediaHandlerRefreshDelegate
- (void)didExpire;
@end

@interface JSQMessagesMediaHandler : NSObject

@property(nonatomic, strong) id <MediaHandlerRefreshDelegate> refreshDelegate;

@property(nonatomic, strong) NSDate *expirationDate;

@property(nonatomic, copy) DidFinishCountingDownHandler didFinishCountingDownHandler;

+ (instancetype)mediaHandlerWithCell:(JSQMessagesCollectionViewCell *)cell;

- (void) setMediaFromImage:(UIImage *)image;
- (void) setMediaFromURL:(NSURL *)imageURL;

- (void) cellWillBeReused;

- (void)manageUpdates;
@end
