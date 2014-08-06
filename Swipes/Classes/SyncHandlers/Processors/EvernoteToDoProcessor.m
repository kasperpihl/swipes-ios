//
//  EvernoteToDoProcessor.m
//  EvernoteSDK_Test
//
//  Created by demosten on 2/24/14.
//

#import "UtilityClass.h"
#import "EvernoteIntegration.h"
#import "EvernoteToDoProcessor.h"

///////////////////////////////////////////////////////////////
// EvernoteToDo
///////////////////////////////////////////////////////////////
@interface EvernoteToDo ()

- (instancetype)initWithTitle:(NSString *)title checked:(BOOL)checked position:(NSInteger)position;

@end

@implementation EvernoteToDo
-(void)setChecked:(BOOL)checked{
    _checked = checked;
}
- (instancetype)initWithTitle:(NSString *)title checked:(BOOL)checked position:(NSInteger)position
{
    self = [super init];
    if (self) {
        _title = title;
        _checked = checked;
        _position = position;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"EvernoteToDo -> title: %@, checked: %@, position: %ld", _title, _checked ? @"YES" : @"NO", (long)_position];
}

@end

///////////////////////////////////////////////////////////////
// EvernoteToDoProcessor
///////////////////////////////////////////////////////////////

static NSSet* g_startEndElements;

@interface EvernoteToDoProcessor () <NSXMLParserDelegate>


@property (nonatomic, strong) NSString *updatedContent;

@end

@implementation EvernoteToDoProcessor {
    NSMutableString* _tempToDoText;
    NSMutableArray* _todos;
    BOOL _checked;
    NSUInteger _untitledCount;
}

+(void)processorWithGuid:(NSString *)guid block:(EvernoteProcessorBlock)block{
    __block EvernoteToDoProcessor *processor = [[EvernoteToDoProcessor alloc] initWithGuid:guid block:^(BOOL succeeded, NSError *error) {
        if( succeeded )
            block(processor, nil);
        else
            block(nil, error);
    }];
}

+ (void)initialize
{
    g_startEndElements = [NSSet setWithArray:@[@"div", @"br", @"table", @"tr", @"td", @"ul", @"li", @"ol", @"en-media", @"hr", @"en-note"]];
}

- (instancetype)initWithGuid:(NSString *)guid block:(SuccessfulBlock)block
{
    self = [super init];
    if (self) {
        self.guid = guid;
        _note = nil;
        [kEnInt fetchNoteWithGuid:guid block:^(EDAMNote *note, NSError *error) {
            if(note){
                _note = note;
                [self parseAndLoadTodos];
                if(block)
                    block(YES,nil);
            }
            else if(block)
                block(NO,error);
        }];
    }
    return self;
}

-(void)parseAndLoadTodos{
    // parse
    _untitledCount = 1;
    _todos = [NSMutableArray array];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[_note.content dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    parser.delegate = self;
    if (![parser parse]) {
        [UtilityClass sendError:parser.parserError type:@"Evernote note parse error"];
    }
}

- (NSArray *)toDoItems
{
    return _todos;
}

- (void)finishCurrentToDo
{
    if (nil != _tempToDoText) {
        // we have a TODO
        NSString* todoText = [_tempToDoText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (0 == todoText.length) {
            todoText = [NSString stringWithFormat:@"Untitled %lu", (unsigned long)_untitledCount++];
        }
//        NSLog(@"Found TODO: %@", todoText);
        [_todos addObject:[[EvernoteToDo alloc] initWithTitle:todoText checked:_checked position:_todos.count]];
        _tempToDoText = nil;
    }
}

- (void)finishIfNeededForElement:(NSString *)elementName
{
    NSString* el = [elementName lowercaseString];
    if ([g_startEndElements containsObject:el]) {
        [self finishCurrentToDo];
    }
}

-(void)saveToEvernote:(SuccessfulBlock)block{
    if( !self.updatedContent )
        return block ? block(NO,nil) : nil;
    EDAMNote* update = [[EDAMNote alloc] init];
    update.guid = _note.guid;
    update.title = _note.title;
    update.content = self.updatedContent;
    [kEnInt saveNote:update block:^(EDAMNote *note, NSError *error) {
        if(error){
            NSDictionary *attachment = @{@"org content":_note.content, @"new content": self.updatedContent};
            [UtilityClass sendError:error type:@"Evernote Save Note Error" attachment:attachment];
            if( block)
                block( NO,error);
        }
        else{
            if( block )
                block( YES, nil );
        }
    }];

}

- (BOOL)updateToDo:(EvernoteToDo *)updatedToDo checked:(BOOL)checked
{
    if ((nil != updatedToDo) && (updatedToDo.checked != checked)) {
        //NSLog(@"now we can update our TODO: %@", updatedToDo);
        
        if (!self.updatedContent)
            self.updatedContent = _note.content;
        
        NSScanner* scanner = [NSScanner scannerWithString:self.updatedContent];
        for (NSInteger i = 0; i <= updatedToDo.position; i++) {
            if (![scanner scanUpToString:@"<en-todo" intoString:nil]) {
                return NO;
            }
            scanner.scanLocation += 8;
//            DLog(@"pos: %d", scanner.scanLocation);
        }
        
        NSUInteger startLocation = scanner.scanLocation;
        
        // get to the next '/' or '>'
        NSUInteger endLocation = startLocation;
        while (('>' != [self.updatedContent characterAtIndex:endLocation]) && ('/' != [self.updatedContent characterAtIndex:endLocation])) {
            endLocation++;
            if (endLocation >= self.updatedContent.length)
                return NO;
        }
        
        NSRange range = NSMakeRange(startLocation, endLocation - startLocation);
        NSString* replaceString = [NSString stringWithFormat:@" checked=\"%@\"", checked ? @"true" : @"false"];
        self.updatedContent = [self.updatedContent stringByReplacingCharactersInRange:range withString:replaceString];
        self.needUpdate = YES;
        DLog(@"successfully went through updating content local");
        return YES;
    }
    else {
        NSLog(@"Cannot find TODO: %@ (or found but already with the same status)", updatedToDo);
    }
    return NO;
}

- (BOOL)updateToDo:(EvernoteToDo *)updatedToDo title:(NSString *)title
{
    if ((nil != updatedToDo) && (![updatedToDo.title isEqualToString:title])) {
        //NSLog(@"now we can update our TODO: %@", updatedToDo);
        
        if (!self.updatedContent)
            self.updatedContent = _note.content;
        
        NSScanner* scanner = [NSScanner scannerWithString:self.updatedContent];
        for (NSInteger i = 0; i <= updatedToDo.position; i++) {
            if (![scanner scanUpToString:@"<en-todo" intoString:nil]) {
                return NO;
            }
            scanner.scanLocation += 8;
//            DLog(@"pos: %d", scanner.scanLocation);
        }
        
        NSString* escapedOldTitle = [self xmlEscape:updatedToDo.title];
        if (![scanner scanUpToString:escapedOldTitle intoString:nil]) {
            return NO;
        }
        
        NSUInteger startLocation = scanner.scanLocation;
        if (startLocation + escapedOldTitle.length > self.updatedContent.length) {
            NSLog(@"Cannot find title: '%@' to replace it with: '%@'", updatedToDo.title, title);
            return NO;
        }
        
        NSRange range = NSMakeRange(startLocation, escapedOldTitle.length);
        self.updatedContent = [self.updatedContent stringByReplacingCharactersInRange:range withString:[self xmlEscape:title]];
        self.needUpdate = YES;
        NSLog(@"successfully went through updating content local (title)");
        
        return YES;
    }
    else {
        NSLog(@"Cannot find TODO: %@", updatedToDo);
    }
    return NO;
}

- (NSString *)xmlEscape:(NSString *)s
{
    NSMutableString* str = s.mutableCopy;
    
    [str replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    
    return str;
}

- (NSUInteger)newToDoPosAtTheBeginning
{
    NSRange div = [self.updatedContent rangeOfString:@"<en-note"];
    if (NSNotFound != div.location) {
        NSUInteger loc = [self.updatedContent rangeOfString:@">" options:NSLiteralSearch range:NSMakeRange(div.location, self.updatedContent.length - div.location - 1)].location;
        return (NSNotFound != loc) ? loc + 1 : loc;
    }
    return div.location;
}

- (NSUInteger)newToDoPos
{
    if (_todos.count) {
        EvernoteToDo* todo = _todos[_todos.count - 1];
        NSScanner* scanner = [NSScanner scannerWithString:self.updatedContent];
        for (NSInteger i = 0; i <= todo.position; i++) {
            if (![scanner scanUpToString:@"<en-todo" intoString:nil]) {
                return [self newToDoPosAtTheBeginning];
            }
            scanner.scanLocation += 8;
        }
        
        NSString* escapedTitle = [self xmlEscape:todo.title];
        
        if (![scanner scanUpToString:escapedTitle intoString:nil]) {
            return [self newToDoPosAtTheBeginning];
        }
        
        NSUInteger tempResult = scanner.scanLocation + escapedTitle.length;
        if ([scanner scanUpToString:@"</div>" intoString:nil]) {
            return scanner.scanLocation + 6; // 6 is the length of @"</div>"
        }
        
        return tempResult;
    }
    else {
        return [self newToDoPosAtTheBeginning];
    }
}

- (BOOL)addToDoWithTitle:(NSString *)title
{
    if (!self.updatedContent)
        self.updatedContent = _note.content;
    
    NSUInteger startPos = [self newToDoPos];
    
    if (startPos >= self.updatedContent.length) {
        //NSLog(@"Evernote error: found position is uncorrect");
        [UtilityClass sendError:[NSError errorWithDomain:@"Evernote error: addToDoWithTitle found position is uncorrect" code:603 userInfo:nil] type:@"Evernote add todo with title" attachment:@{@"start pos": @(startPos), @"updatedContent": self.updatedContent, @"content_length": @(self.updatedContent.length)}];
        return NO;
    }
    
    if (NSNotFound != startPos) {
        self.updatedContent = [self.updatedContent stringByReplacingCharactersInRange:NSMakeRange(startPos, 0)
                                                                           withString:[NSString stringWithFormat:@"<div><en-todo/>%@<br/></div>", [self xmlEscape:title]]];
        self.needUpdate = YES;
        return YES;
    }
    
    return NO;
}

#pragma mark - NSXmlParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //DLog(@"didStartElement: %@ at line: %d:%d", elementName, parser.lineNumber, parser.columnNumber);
    if ([elementName isEqualToString:@"en-todo"]) {
        [self finishCurrentToDo];
        _tempToDoText = [NSMutableString string];
        NSString* strChecked = attributeDict[@"checked"];
        _checked = [[strChecked lowercaseString] isEqualToString:@"true"];
    }
    else if (nil != _tempToDoText) {
        [self finishIfNeededForElement:elementName];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //DLog(@"didEndElement: %@", elementName);
    if (nil != _tempToDoText) {
        [self finishIfNeededForElement:elementName];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //DLog(@"found characters: %@", string);
    if (nil != _tempToDoText) {
        [_tempToDoText appendString:string];
    }
}

@end
