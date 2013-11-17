#import "KPParseObject.h"
#import "KPParseCoreData.h"

@interface KPParseObject ()
@property (nonatomic,strong) NSMutableDictionary *downloadingKeys;
@property (nonatomic,strong) NSMutableDictionary *downloadingBlocks;
@property (nonatomic,strong) PFObject *pfObject;
@end



@implementation KPParseObject
@synthesize pfObject = _pfObject;
@synthesize downloadingKeys = _downloadingKeys;
@synthesize downloadingBlocks = _downloadingBlocks;
#pragma mark - Getters and Setters
-(NSMutableDictionary *)downloadingBlocks{
    if(!_downloadingBlocks) _downloadingBlocks = [NSMutableDictionary dictionary];
    return _downloadingBlocks;
}
-(NSMutableDictionary *)downloadingKeys{
    if(!_downloadingKeys) _downloadingKeys = [NSMutableDictionary dictionary];
    return _downloadingKeys;
}
#pragma mark - Forward declarations
-(void)updateWithObject:(PFObject *)object context:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    [context performBlockAndWait:^{
        self.pfObject = nil;
        if(!self.objectId){
            self.objectId = object.objectId;
            self.createdAt = object.createdAt;
            self.parseClassName = object.parseClassName;
        }
        self.updatedAt = object.updatedAt;
    }];
}
-(BOOL)setAttributesForSavingObject:(PFObject**)object changedAttributes:(NSArray *)changedAttributes{ return NO; }
//-(void)finishedSaving:(BOOL)successful error:(NSError*)error{ }
#pragma mark - Handling of changes
#pragma mark - Instantiate object
+(KPParseObject *)newObjectInContext:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    KPParseObject *coreDataObject;
    coreDataObject = [[self class] MR_createInContext:context];
    return coreDataObject;
}
+(KPParseObject *)getCDObjectFromObject:(PFObject*)object context:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    __block KPParseObject *coreDataObject;
    coreDataObject = [self objectById:object.objectId context:context];
    if(!coreDataObject){
        coreDataObject = [[self class] MR_createInContext:context];
    }
    return coreDataObject;
}
+(KPParseObject *)objectById:(NSString *)identifier context:(NSManagedObjectContext*)context{
    if(!context) context = [KPCORE context];
    KPParseObject *object = [[self class] MR_findFirstByAttribute:@"objectId" withValue:identifier inContext:context];
    return object;
}
+(BOOL)deleteObjectById:(NSString *)identifier context:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    KPParseObject *coreDataObject;
    coreDataObject = [self objectById:identifier context:context];
    BOOL successful = YES;
    if(coreDataObject) successful = [coreDataObject MR_deleteInContext:context];
    return successful;
}
#pragma mark - Save to server
-(PFObject*)emptyObjectForSaving{
    NSString *className = NSStringFromClass ([self class]);
    NSString *parseClassName = [className substringFromIndex:2];
    PFObject *objectToSave;
    objectToSave = [PFObject objectWithClassName:parseClassName];
    if(self.objectId) objectToSave = [PFObject objectWithoutDataWithClassName:parseClassName objectId:self.objectId];
    if(self.pfObject) objectToSave = self.pfObject;
    else self.pfObject = objectToSave;
    
    return objectToSave;
}
-(PFObject*)objectToSaveInContext:(NSManagedObjectContext *)context{
    if(!context) context = [KPCORE context];
    __block BOOL shouldUpdate = NO;
    __block PFObject *objectToSave;
    [context performBlockAndWait:^{
        objectToSave = [self emptyObjectForSaving];
        NSMutableSet *changeSet = [KPCORE.updateObjects objectForKey:self.objectId];
        NSArray *changedAttributes;
        if(changeSet) changedAttributes = [changeSet allObjects];
        shouldUpdate = [self setAttributesForSavingObject:&objectToSave changedAttributes:changedAttributes];
    }];
    if(shouldUpdate)return objectToSave;
    else return nil;
}
+(PFObject *)objectForDeletionWithClassName:(NSString *)className objectId:(NSString *)objectId{
    PFObject *object = [PFObject objectWithoutDataWithClassName:className objectId:objectId];
    [object setObject:@YES forKey:@"deleted"];
    return object;
}
#pragma mark - Handle PFFile
-(void)downloadFile:(PFFile*)file forKey:(NSString*)key withCompletion:(DataBlock)block{
    BOOL isAlreadyDownloading = [[self.downloadingKeys objectForKey:key] boolValue];
    if(!isAlreadyDownloading){
        [self.downloadingKeys setObject:[NSNumber numberWithBool:YES] forKey:key];
        __weak KPParseObject *weakSelf = self;
        [PC downloadFile:file priority:YES withCompletionBlock:^(KPDLResult result, NSData *data, NSError *error) {
            if(weakSelf) [weakSelf.downloadingKeys removeObjectForKey:key];
            if(weakSelf) [weakSelf endedKey:key withResult:result data:data error:error];
        }];
    }
}
-(void)setFile:(PFFile*)file forKey:(NSString*)key{
    if(file && key){
        if(!file.isDataAvailable) [self downloadFile:file forKey:key withCompletion:nil];
        @try{
            [self setValue:file.name forKey:key];
        }
        @catch(NSException * e){
            
        }
    }
}
-(void)addDownloadingBlock:(DataBlock)block forKey:(NSString*)key{
    if(block){
        NSArray *blockArray;
        NSArray *existingBlockArray = [self.downloadingBlocks objectForKey:key];
        if(existingBlockArray){
            blockArray = [existingBlockArray arrayByAddingObject:[block copy]];
        }
        else blockArray = @[[block copy]];
        [self.downloadingBlocks setObject:blockArray forKey:key];
    }
}
-(void)getDataforKey:(NSString*)key withCompletion:(DataBlock)downloadComplete{
    if(downloadComplete) {
        [self addDownloadingBlock:downloadComplete forKey:key];
    }
    BOOL isAlreadyDownloading = [[self.downloadingKeys objectForKey:key] boolValue];
    if(isAlreadyDownloading){
        downloadComplete(KPDLResultDownloading,nil,nil);
        return;
    }
    NSString *pfFileName;
    @try{
        pfFileName = [self valueForKey:key];
    }
    @catch(NSException * e){
        [self endedKey:key withResult:KPDLResultError data:nil error:[NSError errorWithDomain:@"property does not exist" code:1337 userInfo:nil]];
        return;
    }
    if (pfFileName && pfFileName.length >0) {
        NSString *fullPath = parseFileCachePath(pfFileName);
        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
        {
            NSData *returnData =[NSData dataWithContentsOfFile:fullPath];
            if (downloadComplete) {
                [self endedKey:key withResult:KPDLResultSuccess data:returnData error:nil];
            }
        }else{
            [self refreshDataIfPossibleForKey:key withCompletion:downloadComplete];
        }
    }else{
        [self refreshDataIfPossibleForKey:key withCompletion:downloadComplete];
    }
}
-(void)refreshDataIfPossibleForKey:(NSString*)key withCompletion:(DataBlock)downloadComplete{
    PFObject *emptyObject = [PFObject objectWithoutDataWithClassName:self.parseClassName objectId:self.objectId];
    __weak KPParseObject *weakSelf = self;
    [emptyObject refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            PFFile *pfImageFile = [object valueForKey:key];
            if(weakSelf) [weakSelf downloadFile:pfImageFile forKey:key withCompletion:downloadComplete];
        }else{
            if (downloadComplete) downloadComplete(KPDLResultError, nil, error);
        }
    }];
}
-(void)endedKey:(NSString*)key withResult:(KPDLResult)result data:(NSData*)data error:(NSError*)error{
    NSArray *blocks = [self.downloadingBlocks objectForKey:key];
    if(blocks && blocks.count > 0){
        for (int i = 0; i < blocks.count; i++) {
            DataBlock block = [blocks objectAtIndex:i];
            block(result,data,error);
        }
        [self.downloadingBlocks removeObjectForKey:key];
    }
}

@end
