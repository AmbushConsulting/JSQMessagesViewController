#import "VHighlightingTextStorage.h"

/**
 *  Based on what i've learned reading http://www.objc.io/issue-5/getting-to-know-textkit.html
 */

@implementation VHighlightingTextStorage
{
	NSMutableAttributedString *_backingStore;
}

- (id)init
{
	self = [super init];
	
	if (self) {
		_backingStore = [NSMutableAttributedString new];
	}
	
	return self;
}


#pragma mark - Reading Text

- (NSString *)string
{
	return _backingStore.string;
}

- (NSUInteger)length
{
    return [_backingStore length];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    NSDictionary *attributes = [_backingStore attributesAtIndex:location effectiveRange:range];
	return attributes;
}

#pragma mark - Text Editing

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
	[_backingStore replaceCharactersInRange:range withString:str];
	[self edited:NSTextStorageEditedCharacters range:range changeInLength:(NSInteger)str.length - (NSInteger)range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];

	[_backingStore setAttributes:attrs range:range];
	[self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    
    [self endEditing];
}

#pragma mark - Syntax highlighting

- (void)processEditing
{
    if (self.editedMask & NSTextStorageEditedCharacters)
    {
        [self highlightVoalteExtensions];
        [self highlightHyperlink];
    }

    [super processEditing];
}

#pragma mark - Private

- (void) highlightHyperlink
{
    static NSRegularExpression *linkDetector;
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        linkDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:NULL];
    });
    
    [linkDetector enumerateMatchesInString:self.string
                                   options:0
                                     range:NSMakeRange(0, self.string.length)
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        [self addAttribute:NSLinkAttributeName value:result.URL range:result.range];
    }];

}

- (void) highlightVoalteExtensions
{
	static NSRegularExpression *iExpression;
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *pattern = @"\\d{3}-\\d{3}-\\d{4}\\s(x|(ext))\\d{3,5}|\\d{3}[-\\.\\s]\\d{3}[-\\.\\s]\\d{4}|\\d{10}|\\(\\d{3}\\)-\\d{3}-\\d{4}|\\d{5}|\\d{4}";
        iExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    });
	
	[iExpression enumerateMatchesInString:self.string
                                  options:0
                                    range:NSMakeRange(0, self.string.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSString *phone = [[self.string substringWithRange:result.range] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"vone://%@", phone]];
         [self addAttribute:NSLinkAttributeName value:url range:result.range];
     }];
}

@end
