//
//  EvernoteToDoProcessor.m
//
//  Created by demosten on 2/24/14.
//

#import "UtilityClass.h"
#import "KPStringScanner.h"
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
}

+ (void)processorWithNoteRefString:(NSString *)noteRefString block:(EvernoteProcessorBlock)block
{
    __block EvernoteToDoProcessor *processor = [[EvernoteToDoProcessor alloc] initWithNoteRefString:noteRefString block:^(BOOL succeeded, NSError *error) {
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

- (instancetype)initWithNoteRefString:(NSString *)noteRefString block:(SuccessfulBlock)block
{
    self = [super init];
    if (self) {
        self.noteRefString = noteRefString;
        _note = nil;
        [kEnInt downloadNoteWithRef:[EvernoteIntegration NSStringToENNoteRef:noteRefString] block:^(ENNote *note, NSError *error) {
            if (note) {
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

-(void)parseAndLoadTodos
{
    // parse
    _todos = [NSMutableArray array];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[_note.content.enml dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    parser.delegate = self;
    if (![parser parse]) {
        NSError* newError = [NSError errorWithDomain:parser.parserError.domain code:605 userInfo:parser.parserError.userInfo]; // change error code to something known
        [UtilityClass sendError:newError type:@"Evernote note parse error" attachment:@{@"content": _note.content.enml}];
    }
}

- (NSArray *)toDoItems
{
    NSMutableArray* validTodos = [_todos mutableCopy];
    for (EvernoteToDo* todo in _todos) {
        if (nil == todo.title) {
            [validTodos removeObject:todo];
        }
    }
    return validTodos;
}

- (void)finishCurrentToDo
{
    if (nil != _tempToDoText) {
        // we have a TODO
        NSString* todoText = [_tempToDoText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (0 == todoText.length) {
            todoText = nil;
        }
        if(255 < todoText.length){
            todoText = [todoText substringToIndex:255];
        }
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
        return block ? block(NO, nil) : nil;
    _note.content = [[ENNoteContent alloc] initWithENML:self.updatedContent];
//    _note.content = [[ENNoteContent alloc] initWithENML:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n<en-note><div><em><span style=\"font-family: helvetica, arial, sans-serif; font-size: 18px;\">CLIENT FOLDER</span></em></div><div><br clear=\"none\"/></div><div><strong>TASKS</strong></div><div><strong><strong><en-todo></en-todo></strong></strong>Scott to push hard for analyst recognition in Amundi's 2014 vote (Joe, Peach?)<div><br clear=\"none\"/></div><div><strong>KEY HOLDINGS</strong><br clear=\"none\"/></div><div><br clear=\"none\"/></div><div><div><strong>RELATIONSHIP AND VOTE HISTORY</strong></div><div>Nij was covering Amundi previously and struggled to get air-time with Timothy. I know Timothy from before, so it was relatively easy to get his attention once Carolyn made the introduction. Since then (April/May?) have had fairly regular contact.<br clear=\"none\"/></div><div><br clear=\"none\"/></div><div>For the last few votes, we have been &quot;Not Rated&quot; (which means outside of Top 12). The 2014 vote should be out in December 2014 or January 2015</div></div><div><br clear=\"none\"/></div><div><strong>OCTOBER 2014</strong></div><ul><li>Tim request on property sector<br clear=\"none\"/></li><li>Tim call with Joe Phanich on telcos</li><li>Scott dropped of new research/sales materials package</li></ul><div><strong>NOVEMBER 2014</strong></div><ul><li>Tim taking VGI meeting<br clear=\"none\"/></li><li>Carolyn made comment to me that &quot;Tim has already said he's seen a big pick-up in service...so that should be reflected in a higher ranking.&quot;</li></ul></div></en-note>"];
    [kEnInt updateNote:_note noteRef:[EvernoteIntegration NSStringToENNoteRef:self.noteRefString] block:^(ENNoteRef *noteRef, NSError *error) {
        if (error) {
            NSDictionary *attachment = @{@"org content":_note.content.enml, @"new content": self.updatedContent};
            NSError* newError = [NSError errorWithDomain:error.domain code:604 userInfo:error.userInfo]; // change error code to something known
            [UtilityClass sendError:newError type:@"Evernote Save Note Error" attachment:attachment];
            if (block)
                block(NO, error);
        }
        if (noteRef && block) {
            block(YES, nil);
        }
        if ((!noteRef) && (!error) && block) {
            block(NO, nil);
        }
    }];
}

- (BOOL)updateToDo:(EvernoteToDo *)updatedToDo checked:(BOOL)checked
{
    if ((nil != updatedToDo) && (updatedToDo.checked != checked)) {
        if (!self.updatedContent)
            self.updatedContent = _note.content.enml;
        
        KPStringScanner* scanner = [KPStringScanner scannerWithString:self.updatedContent];
        for (NSInteger i = 0; i <= updatedToDo.position; i++) {
            if (![scanner scanToAfterString:@"<en-todo"]) {
                return NO;
            }
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
        if (!self.updatedContent)
            self.updatedContent = _note.content.enml;
       
        KPStringScanner* scanner = [KPStringScanner scannerWithString:self.updatedContent];
        for (NSInteger i = 0; i <= updatedToDo.position; i++) {
            if (![scanner scanToAfterString:@"<en-todo"]) {
                return NO;
            }
        }
        
        NSString* escapedOldTitle = [self xmlEscape:updatedToDo.title];
        if (![scanner scanUpToString:escapedOldTitle]) {
            return NO;
        }
        
        NSUInteger startLocation = scanner.scanLocation;
        if (startLocation + escapedOldTitle.length > self.updatedContent.length) {
            [UtilityClass sendError:[NSError errorWithDomain:@"Evernote error: updateToDo cannot find title" code:606 userInfo:nil] type:@"Evernote update ToDo" attachment:@{@"title": updatedToDo.title, @"replacement title": title, @"updatedContent": self.updatedContent}];
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
    [str replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    [str replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    //[str replaceOccurrencesOfString:@"'"  withString:@"&#x27;" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
    
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

- (EvernoteToDo *)lastValidTodo
{
    for (NSInteger i = _todos.count - 1; i >= 0; i--) {
        EvernoteToDo* todo = _todos[i];
        if (nil != todo.title) {
            return todo;
        }
    }
    return nil;
}

- (NSUInteger)newToDoPos
{
    if (_todos.count) {
        EvernoteToDo* todo = [self lastValidTodo];
        if (nil == todo) {
            return [self newToDoPosAtTheBeginning];
        }
        KPStringScanner* scanner = [KPStringScanner scannerWithString:self.updatedContent];
        for (NSInteger i = 0; i <= todo.position; i++) {
            if (![scanner scanToAfterString:@"<en-todo" ]) {
                return [self newToDoPosAtTheBeginning];
            }
        }
        
        NSString* escapedTitle = [self xmlEscape:todo.title];
        
        if (![scanner scanToAfterString:escapedTitle]) {
            return [self newToDoPosAtTheBeginning];
        }
        
        [scanner scanToAfterString:@"</div>"];
        return scanner.scanLocation;
    }
    else {
        return [self newToDoPosAtTheBeginning];
    }
}

- (BOOL)addToDoWithTitle:(NSString *)title
{
    if (!self.updatedContent)
        self.updatedContent = _note.content.enml;
    
    NSUInteger startPos = [self newToDoPos];
    
    if (startPos >= self.updatedContent.length) {
        //NSLog(@"Evernote error: found position is uncorrect");
        [UtilityClass sendError:[NSError errorWithDomain:@"Evernote error: addToDoWithTitle found position is not correct" code:603 userInfo:nil] type:@"Evernote add todo with title" attachment:@{@"start pos": @(startPos), @"updatedContent": self.updatedContent, @"content_length": @(self.updatedContent.length)}];
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
