/*
 <codex>
 <abstract>
 Mediator object for managing multiple hud objects for n-body simulators.
 </abstract>
 </codex>
 */

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@interface NBodyMeters: NSObject

@property (nonatomic, readonly) size_t count;

@property (nonatomic) BOOL         isVisible;
@property (nonatomic) BOOL         useTimer;
@property (nonatomic) BOOL         useHostInfo;
@property (nonatomic) std::string  label;
@property (nonatomic) size_t       index;
@property (nonatomic) size_t       max;
@property (nonatomic) GLsizei      bound;
@property (nonatomic) GLfloat      speed;
@property (nonatomic) GLfloat      value;
@property (nonatomic) CGSize       frame;
@property (nonatomic) CGPoint      point;

- (instancetype) initWithCount:(size_t)count;

- (BOOL) acquire;

- (void) toggle;
- (void) show:(BOOL)doShow;

- (void) update;
- (void) reset;

- (void) resize:(NSSize)size;

- (void) draw;
- (void) draw:(NSArray *)positions;

@end
