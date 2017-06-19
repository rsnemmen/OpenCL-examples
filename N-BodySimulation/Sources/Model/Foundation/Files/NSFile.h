/*
 <codex>
 <abstract>
 Objective-C language binding for CFFile utilities.
 </abstract>
 </codex>
 */

#import <Cocoa/Cocoa.h>

@interface NSFile : NSObject <NSCopying>

@property (nonatomic, readonly) id plist;

@property (nonatomic, readonly) NSURL*          url;
@property (nonatomic, readonly) NSMutableData*  data;
@property (nonatomic, readonly) NSString*       string;

@property (nonatomic, readonly) const char*    cstring;
@property (nonatomic, readonly) const uint8_t* bytes;

@property (nonatomic, readonly) BOOL                   isPList;
@property (nonatomic, readonly) NSInteger              length;
@property (nonatomic, readonly) NSPropertyListFormat   format;
@property (nonatomic, readonly) NSSearchPathDirectory  directory;
@property (nonatomic, readonly) NSSearchPathDomainMask domain;

- (instancetype) initWithPathname:(NSString *)pathname;

- (instancetype) initWithResourceInAppBundle:(NSString *)fileName
                                   extension:(NSString *)fileExt;

- (instancetype) initWithDomain:(NSSearchPathDomainMask)domain
                         search:(NSSearchPathDirectory)directory
                      directory:(NSString *)dirName
                           file:(NSString *)fileName
                      extension:(NSString *)fileExt;

- (instancetype) initWithFile:(NSFile *)file;

+ (instancetype) fileWithPathname:(NSString *)pathname;

+ (instancetype) fileWithResourceInAppBundle:(NSString *)fileName
                                   extension:(NSString *)fileExt;

+ (instancetype) fileWithDomain:(NSSearchPathDomainMask)domain
                         search:(NSSearchPathDirectory)directory
                      directory:(NSString *)dirName
                           file:(NSString *)fileName
                      extension:(NSString *)fileExt;

+ (instancetype) fileWithFile:(NSFile *)file;

- (void) replace:(id)plist;

- (BOOL) write;

- (BOOL) write:(NSString *)pathname;

- (BOOL) write:(NSString *)fileName
     extension:(NSString *)fileExt;

@end
