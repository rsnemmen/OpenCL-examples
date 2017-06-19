/*
 <codex>
 <abstract>
 Utility class for managing application's preferences and settings.
 </abstract>
 </codex>
 */

#import <Cocoa/Cocoa.h>

// Keys for the preferences dictionary     // For values
extern NSString* kNBodyPrefDemos;          // Signed integer 64
extern NSString* kNBodyPrefDemoType;       // Unsigned Integer 32
extern NSString* kNBodyPrefParticles;      // Unsigned Integer 32
extern NSString* kNBodyPrefConfig;         // Unsigned Integer 32
extern NSString* kNBodyPrefMaxUpdates;     // Unsigned Long
extern NSString* kNBodyPrefMaxFrameRate;   // Unsigned Long
extern NSString* kNBodyPrefMaxPerf;        // Unsigned Long
extern NSString* kNBodyPrefMaxCPU;         // Unsigned Long
extern NSString* kNBodyPrefRotateX;        // Double
extern NSString* kNBodyPrefRotateY;        // Double
extern NSString* kNBodyPrefSizeWidth;      // Double
extern NSString* kNBodyPrefSizeHeight;     // Double
extern NSString* kNBodyPrefClearColor;     // Float
extern NSString* kNBodyPrefStarScale;      // Float
extern NSString* kNBodyPrefViewDistance;   // Float
extern NSString* kNBodyPrefTimeStep;       // Float
extern NSString* kNBodyPrefClusterScale;   // Float
extern NSString* kNBodyPrefVelocityScale;  // Float
extern NSString* kNBodyPrefSoftening;      // Float
extern NSString* kNBodyPrefDamping;        // Float
extern NSString* kNBodyPrefPointSize;      // Float
extern NSString* kNBodyPrefFullScreen;     // BOOL
extern NSString* kNBodyPrefIsGPUOnly;      // BOOL
extern NSString* kNBodyPrefShowUpdates;    // BOOL
extern NSString* kNBodyPrefShowFrameRate;  // BOOL
extern NSString* kNBodyPrefShowPerf;       // BOOL
extern NSString* kNBodyPrefShowDock;       // BOOL
extern NSString* kNBodyPrefShowCPU;        // BOOL

@interface NBodyPreferences : NSObject

@property (nonatomic, readonly) NSString*     identifier;
@property (nonatomic, readonly) NSDictionary* preferences;

@property (nonatomic) int64_t demos;

@property (nonatomic) uint32_t demoType;
@property (nonatomic) uint32_t config;
@property (nonatomic) uint32_t particles;

@property (nonatomic) size_t maxUpdates;
@property (nonatomic) size_t maxFramerate;
@property (nonatomic) size_t maxPerf;
@property (nonatomic) size_t maxCPU;

@property (nonatomic) NSPoint rotate;
@property (nonatomic) NSSize  size;

@property (nonatomic) float  timeStep;
@property (nonatomic) float  clusterScale;
@property (nonatomic) float  velocityScale;
@property (nonatomic) float  softening;
@property (nonatomic) float  damping;
@property (nonatomic) float  pointSize;
@property (nonatomic) float  starScale;
@property (nonatomic) float  viewDistance;
@property (nonatomic) float  clearColor;

@property (nonatomic) BOOL  isGPUOnly;
@property (nonatomic) BOOL  fullscreen;
@property (nonatomic) BOOL  showUpdates;
@property (nonatomic) BOOL  showFramerate;
@property (nonatomic) BOOL  showCPU;
@property (nonatomic) BOOL  showPerf;
@property (nonatomic) BOOL  showDock;

+ (instancetype) preferences;

- (BOOL) addEntries:(NBodyPreferences *)preferences;

- (BOOL) write;

@end
