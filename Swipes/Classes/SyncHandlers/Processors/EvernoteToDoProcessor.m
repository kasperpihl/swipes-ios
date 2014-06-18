//
//  EvernoteToDoProcessor.m
//  EvernoteSDK_Test
//
//  Created by demosten on 2/24/14.
//

#import <Evernote-SDK-iOS/EvernoteSDK.h>

#import "EvernoteToDoProcessor.h"

///////////////////////////////////////////////////////////////
// EvernoteToDo
///////////////////////////////////////////////////////////////
@interface EvernoteToDo ()

- (instancetype)initWithTitle:(NSString *)title checked:(BOOL)checked position:(NSInteger)position;

@end

@implementation EvernoteToDo

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
    return [NSString stringWithFormat:@"EvernoteToDo -> title: %@, checked: %@, position: %d", _title, _checked ? @"YES" : @"NO", _position];
}

@end

///////////////////////////////////////////////////////////////
// EvernoteToDoProcessor
///////////////////////////////////////////////////////////////

static NSSet* g_startEndElements;

@interface EvernoteToDoProcessor () <NSXMLParserDelegate>

@property (nonatomic, strong) EDAMNote* note;

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
        [self loadNoteWithGuid:guid block:block];
    }
    return self;
}

- (void)loadNoteWithGuid:(NSString *)guid block:(SuccessfulBlock)block
{
    _note = nil;
    [[EvernoteNoteStore noteStore] getNoteWithGuid:guid withContent:YES withResourcesData:YES withResourcesRecognition:NO withResourcesAlternateData:NO success:^(EDAMNote *note) {
        _note = note;
        [self parseAndLoadTodos];
        if( block )
            block( YES , nil );
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get note : %@",error);
        if( block )
            block( NO , error );
    }];
}

-(void)parseAndLoadTodos{
    // parse
    _untitledCount = 1;
    _todos = [NSMutableArray array];
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[_note.content dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    parser.delegate = self;
    if (![parser parse]) {
        // TODO get error
        return;
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
            todoText = [NSString stringWithFormat:@"Untitled %u", _untitledCount++];
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


- (BOOL)updateToDo:(EvernoteToDo *)todo checked:(BOOL)checked
{
    NSLog(@"searching for TODO: %@", todo);
    EvernoteToDo* updatedToDo; // = [self updatedVersionOfToDo:todo];
    if ((nil != updatedToDo) && (updatedToDo.checked != checked)) {
        NSLog(@"now we can update our TODO: %@", updatedToDo);
        
        NSScanner* scanner = [NSScanner scannerWithString:_note.content];
        for (NSInteger i = 0; i <= updatedToDo.position; i++) {
            if (![scanner scanUpToString:@"<en-todo" intoString:nil]) {
                return NO;
            }
            scanner.scanLocation += 8;
//            NSLog(@"pos: %d", scanner.scanLocation);
        }
        
        NSUInteger startLocation = scanner.scanLocation;
        if (('>' != [_note.content characterAtIndex:startLocation]) && (![scanner scanUpToString:@">" intoString:nil])) {
            return NO;
        }
        NSUInteger endLocation = scanner.scanLocation;
        
        NSRange range = NSMakeRange(startLocation, endLocation - startLocation);
        NSString* replaceString = [NSString stringWithFormat:@" checked=\"%@\"", checked ? @"true" : @"false"];
        NSString* result = [_note.content stringByReplacingCharactersInRange:range withString:replaceString];
        
//        NSLog(@"result: %@", result);
        
        EDAMNote* update = [[EDAMNote alloc] init];
        update.guid = _note.guid;
        update.title = _note.title;
        update.content = result;
        [[EvernoteNoteStore noteStore] updateNote:update success:^(EDAMNote *note) {
            NSLog(@"note update success !!!");
        } failure:^(NSError *error) {
            NSLog(@"note update failed: %@", [error localizedDescription]);
        }];
        
        return YES;
    }
    else {
        NSLog(@"Cannot find TODO: %@ (or found but already with the same status)", todo);
    }
    return NO;
}

#pragma mark - NSXmlParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"didStartElement: %@ at line: %d:%d", elementName, parser.lineNumber, parser.columnNumber);
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
    //NSLog(@"didEndElement: %@", elementName);
    if (nil != _tempToDoText) {
        [self finishIfNeededForElement:elementName];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"found characters: %@", string);
    if (nil != _tempToDoText) {
        [_tempToDoText appendString:string];
    }
}

@end
