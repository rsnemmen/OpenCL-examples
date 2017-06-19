/*
 <codex>
 <import>NBodyEngine.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <OpenGL/gl.h>

#import "GLMConstants.h"

#import "NBodyConstants.h"
#import "NBodyButtons.h"
#import "NBodyMeters.h"

#import "NBodySimulationMediator.h"
#import "NBodyPreferences.h"
#import "NBodySimulationVisualizer.h"

#import "NBodyEngine.h"

static const size_t kMeterDefaultMaxFPS      = 120;
static const size_t kMeterDefaultMaxUpdates  = 120;
static const size_t kMeterDefaultMaxPerf     = 1400;
static const size_t kMeterDefaultMaxCPUUsage = 100;

@implementation NBodyEngine
{
@private
    // Properties
    BOOL  _isResized;
    BOOL  _fullscreen;
    
    unichar _command;
    
    GLuint   _activeDemo;
    
    GLfloat  _clearColor;
    GLfloat  _viewDistance;
    
    NSSize _size;
    NSRect _frame;
    
    NBodyPreferences* _preferences;
    
    // Instance Variables
    BOOL mbIsWaiting;
    BOOL mbIsRotating;
    
    GLuint  mnSimulatorIndex;
    GLuint  mnSimulatorCount;
    
    GLfloat   mnStarScale;

    GLsizei   mnWidowWidth;
    GLsizei   mnWidowHeight;
    
    NSPoint   m_MousePt;
    NSPoint   m_Rotation;
    
    NBody::Simulation::Properties  m_Properties;

    NBodyMeters*  mpMeters;
    NBodyButtons* mpButtons;
    
    NBody::Simulation::Mediator*   mpMediator;
    NBody::Simulation::Visualizer* mpVisualizer;
}

#pragma mark -
#pragma mark Private - Utiltites - Scene

- (void) _reset
{
    mpVisualizer->stopRotation();
    mpVisualizer->setRotationSpeed(0.0f);
    
    mpMediator->reset();
    mpVisualizer->reset(_activeDemo);
} // _reset

- (void) _restart
{
    mpVisualizer->setViewRotation(m_Rotation);
    mpVisualizer->setViewZoom(_viewDistance);
    mpVisualizer->setViewTime(0.0f);
    mpVisualizer->setIsResetting(YES);
    mpVisualizer->stopRotation();
} // _restart

- (void) _nextSimulator
{
    mbIsWaiting = YES;
    
    mnSimulatorIndex++;
    
    if(mnSimulatorIndex >= mnSimulatorCount)
    {
        mnSimulatorIndex = 0;
    } // if
    
    mpMediator->pause();
    mpMediator->select(mnSimulatorIndex);
    mpMediator->reset();
    
    mpButtons.index      = mnSimulatorIndex;
    mpButtons.size       = _size;
    mpButtons.isSelected = YES;
} // _nextSimulator

- (void) _nextDemo
{
    _activeDemo = (_activeDemo + 1) % m_Properties.mnDemos;
    
    [self _reset];
    
    _preferences.demoType = _activeDemo;
} // _nextDemo

- (void) _swapVisualizer
{
    [self draw];
    
    mbIsWaiting = YES;
    
    mpVisualizer->reset(_activeDemo);
} // _swapVisualizer

- (void) _swapSimulators
{
    [self draw];
    
    [self _nextSimulator];
    
    mpVisualizer->reset(_activeDemo);

    // Reset the target values of meters
    [mpMeters reset];
} // _swapSimulators

- (void) _swapInterval:(const BOOL)doSync
{
    CGLContextObj pContext = CGLGetCurrentContext();
    
    if(pContext != nullptr)
    {
        const GLint sync = GLint(doSync);
        
        CGLSetParameter(pContext,
                        kCGLCPSwapInterval,
                        &sync);
    } // if
} // _swapInterval

- (void) _drawScene
{
    // Render stars
    const GLfloat* pPosition = mpMediator->position();
    
    mpVisualizer->draw(pPosition);
    
    // Update and render the performance meters
    mpMeters.index = NBody::eNBodyMeterFrames;
    mpMeters.point = NSMakePoint(208.0f, 160.0f);
    
    [mpMeters update];
    [mpMeters draw];
    
    mpMeters.index = NBody::eNBodyMeterCPU;
    mpMeters.point = NSMakePoint(208.0f + 0.25f * _size.width, 160.0f);

    [mpMeters update];
    [mpMeters draw];
    
    mpMeters.index = NBody::eNBodyMeterUpdates;
    mpMeters.point = NSMakePoint(0.75f * _size.width - 208.0f, 160.0f);
    mpMeters.value = mpMediator->updates();
    
    [mpMeters update];
    [mpMeters draw];
    
    mpMeters.index = NBody::eNBodyMeterPerf;
    mpMeters.point = NSMakePoint(_size.width - 208.0f, 160.0f);
    mpMeters.value = mpMediator->performance();
    
    [mpMeters update];
    [mpMeters draw];
    
    // Draw the button(s) in the dock
    [mpButtons draw];
} // _drawScene

- (void) _setDemo:(const GLuint)activeDemo
{
    _activeDemo = activeDemo;
    
    [self _reset];
    
    _preferences.demoType = _activeDemo;
} // _setDemo

- (void) _selectDemo:(const unichar)command
{
    if(command != _command)
    {
        GLuint demo = GLuint(command - '0');
        
        if(demo < m_Properties.mnDemos)
        {
            [self _setDemo:demo];
        } // if
        
        _command = command;
    } // if
} // _selectDemo

#pragma mark -
#pragma mark Private - Utiltites - Constructors

- (BOOL) _newSimulators
{
    mpMediator = new (std::nothrow) NBody::Simulation::Mediator(m_Properties);
    
    if(mpMediator != nullptr)
    {
        mnSimulatorIndex = 0;
        mnSimulatorCount = mpMediator->count();
        
        mpMediator->reset();
        mpVisualizer->reset(_activeDemo);
    } // if
    
    return mnSimulatorCount > 0;
} // _newSimulators

- (BOOL) _newVisualizer
{
    mpVisualizer = new (std::nothrow) NBody::Simulation::Visualizer(m_Properties);

    BOOL bSuccess = mpVisualizer != nullptr;

    if(bSuccess)
    {
        bSuccess = mpVisualizer->isValid();
        
        if(bSuccess)
        {
            mpVisualizer->setFrame(_size);
            mpVisualizer->setStarScale(mnStarScale);
            mpVisualizer->setStarSize(NBody::Star::kSize);
            mpVisualizer->setRotationChange(NBody::Defaults::kRotationDelta);
            
            bSuccess =             [self _newSimulators];
            bSuccess = bSuccess && [self _newMeters:NBody::Defaults::kMeterSize];
            bSuccess = bSuccess && [self _newDock:mpMediator->count()];
        } // if
    } // else
    else
    {
        NSLog(@">> ERROR: Failed allocating backing-store for the engine!");
    } // if
    
    return bSuccess;
} // _newVisualizer

- (BOOL) _newDock:(const size_t)count
{
    mpButtons = [[NBodyButtons alloc] initWithCount:count];
    
    if(mpButtons)
    {
        size_t i;
        
        for(i = 0; i < count; ++i)
        {
            mpButtons.index = i;
            mpButtons.label = mpMediator->label(NBody::Simulation::Types(i));
            mpButtons.size  = _size;
            
            if(![mpButtons acquire])
            {
                return NO;
            } // if
        } // for
        
        mpButtons.index = 0;
        
        return YES;
    } // if
    
    return NO;
} // _newDock

- (BOOL) _newMeterFrames:(const GLsizei)length
{
    mpMeters.index     = NBody::eNBodyMeterFrames;
    mpMeters.isVisible = (_preferences) ? _preferences.showFramerate : NO;
    mpMeters.max       = (_preferences) ? _preferences.maxFramerate  : kMeterDefaultMaxFPS;
    mpMeters.bound     = length;
    mpMeters.label     = "Frames/sec";
    mpMeters.useTimer  = YES;
    mpMeters.frame     = _size;
    
    return [mpMeters acquire];
} // _newMeterFrames

- (BOOL) _newMeterUpdates:(const GLsizei)length
{
    mpMeters.index     = NBody::eNBodyMeterUpdates;
    mpMeters.isVisible = (_preferences) ? _preferences.showUpdates : NO;
    mpMeters.max       = (_preferences) ? _preferences.maxUpdates  : kMeterDefaultMaxUpdates;
    mpMeters.bound     = length;
    mpMeters.label     = "Updates/sec";
    mpMeters.frame     = _size;
    
    return [mpMeters acquire];
} // _newMeterUpdates

- (BOOL) _newMeterPerf:(const GLsizei)length
{
    mpMeters.index     = NBody::eNBodyMeterPerf;
    mpMeters.isVisible = (_preferences) ? _preferences.showPerf : YES;
    mpMeters.max       = (_preferences) ? _preferences.maxPerf  : kMeterDefaultMaxPerf;
    mpMeters.bound     = length;
    mpMeters.label     = "Relative Perf";
    mpMeters.frame     = _size;
    
    return [mpMeters acquire];
} // _newMeterPerf

- (BOOL) _newMeterCPU:(const GLsizei)length
{
    mpMeters.index       = NBody::eNBodyMeterCPU;
    mpMeters.isVisible   = (_preferences) ? _preferences.showCPU : YES;
    mpMeters.max         = (_preferences) ? _preferences.maxCPU  : kMeterDefaultMaxCPUUsage;
    mpMeters.bound       = length;
    mpMeters.label       = "% CPU Usage";
    mpMeters.useHostInfo = YES;
    mpMeters.frame       = _size;
    
    return [mpMeters acquire];
} // _newMeterCPU

- (BOOL) _newMeters:(const GLsizei)length
{
    BOOL bSuccess = NO;
    
    mpMeters = [[NBodyMeters alloc] initWithCount:4];
    
    if(mpMeters)
    {
        bSuccess =             [self _newMeterFrames:length];
        bSuccess = bSuccess && [self _newMeterUpdates:length];
        bSuccess = bSuccess && [self _newMeterPerf:length];
        bSuccess = bSuccess && [self _newMeterCPU:length];
    } // if
    
    return bSuccess;
} // _newMeters

- (BOOL) _newPreferences:(NBodyPreferences *)preferences
{
    if(preferences)
    {
        _preferences = [preferences retain];
    } // if
    else
    {
        _preferences = [NBodyPreferences new];
    } // else
    
    return preferences != nil;
} // _newPreferences

#pragma mark -
#pragma mark Private - Utiltites - UI

- (void) _resizeButtons
{
    if(mpButtons)
    {
        mpButtons.index      = mnSimulatorIndex;
        mpButtons.size       = _size;
        mpButtons.isSelected = YES;
    } // if
} // _resizeButtons

- (void) _resizeMeters
{
    if(mpMeters)
    {
        [mpMeters resize:_size];
    } // if
} // _resizeMeters

- (void) _toggleMeter:(const size_t)index
{
    mpMeters.index = index;
    
    [mpMeters toggle];
    
    switch(index)
    {
        case NBody::eNBodyMeterPerf:
            _preferences.showPerf = mpMeters.isVisible;
            break;
            
        case NBody::eNBodyMeterUpdates:
            _preferences.showUpdates = mpMeters.isVisible;
            break;
            
        case NBody::eNBodyMeterCPU:
            _preferences.showCPU = mpMeters.isVisible;
            break;
            
        case NBody::eNBodyMeterFrames:
        default:
            _preferences.showFramerate = mpMeters.isVisible;
            break;
    } // switch
} // _toggleMeter

- (void) _showMeters:(const BOOL)doShow
{
    [mpMeters show:doShow];
    
    _preferences.showPerf      = doShow;
    _preferences.showUpdates   = doShow;
    _preferences.showFramerate = doShow;
    _preferences.showCPU       = doShow;
} // _showMeters

- (void) _setDefaults
{
    _isResized = NO;
    _command   = 0;
    _frame     = NSMakeRect(0.0f, 0.0f, 0.0f, 0.0f);
    
    mbIsWaiting      = YES;
    mbIsRotating     = YES;
    mnSimulatorIndex = 0;
    mnSimulatorCount = 0;
    mnWidowWidth     = GLsizei(_size.width);
    mnWidowHeight    = GLsizei(_size.height);
    m_MousePt        = NSMakePoint(0.0f, 0.0f);
    mpMediator       = nullptr;
    mpVisualizer     = nullptr;
    mpButtons        = nil;
    mpMeters         = nil;
} // _setDefaults

- (void) _setPreferences:(NBodyPreferences *)preferences
{
    if([self _newPreferences:preferences])
    {
        m_Properties = _preferences;

        _activeDemo   = _preferences.demoType;
        _clearColor   = _preferences.clearColor;
        _viewDistance = _preferences.viewDistance;
        _size         = _preferences.size;
        
        mnStarScale = _preferences.starScale;
        m_Rotation  = _preferences.rotate;
    } // if
    else
    {
        _activeDemo   = 1;
        _clearColor   = 1.0f;
        _viewDistance = 30.0f;
        _size         = NSMakeSize(NBody::Window::kWidth, NBody::Window::kHeight);
        
        mnStarScale = 1.0f;
        m_Rotation  = NSMakePoint(0.0f, 0.0f);
    } // else
} // _setPreferences

- (void) _setEnginePreferences:(NBodyPreferences *)preferences
{
    [self _setPreferences:preferences];
    [self _setDefaults];
} // _setEnginePreferences

#pragma mark -
#pragma mark Public

- (instancetype) init
{
    self = [super init];
    
    if(self)
    {
        [self _setEnginePreferences:nil];
    } // if
    
    return self;
} // init

- (instancetype) initWithPreferences:(NBodyPreferences *)preferences
{
    self = [super init];
    
    if(self)
    {
        [self _setEnginePreferences:preferences];
    } // if
    
    return self;
} // if

+ (instancetype) engine
{
    return [[[NBodyEngine allocWithZone:[self zone]] initWithPreferences:nil] autorelease];
} // engine

+ (instancetype) engineWithPreferences:(NBodyPreferences *)preferences
{
    return [[[NBodyEngine allocWithZone:[self zone]] initWithPreferences:preferences] autorelease];
} // engineWithPreferences

- (void) dealloc
{
    if(_preferences)
    {
        [_preferences release];
        
        _preferences = nil;
    } // if
    
    if(mpButtons)
    {
        [mpButtons release];
        
        mpButtons = nil;
    } // if
    
    if(mpMeters)
    {
        [mpMeters release];
        
        mpMeters = nil;
    } // if
    
    if(mpVisualizer != nullptr)
    {
        delete mpVisualizer;
        
        mpVisualizer = nullptr;
    } // if
    
    if(mpMediator != nullptr)
    {
        delete mpMediator;
        
        mpMediator = nullptr;
    } // if

    [super dealloc];
} // dealloc

- (BOOL) acquire
{
    [self _swapInterval:YES];
    
    return [self _newVisualizer];
} // acquire

- (void) draw
{
    mpMediator->update();
    
    glClearColor(_clearColor, _clearColor, _clearColor, 1.0f);
    
    if(_clearColor > 0.0f)
    {
        _clearColor -= 0.05f;
    } // if
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    if(!mpMediator->hasPosition())
    {
        if(mbIsWaiting)
        {
            CGLFlushDrawable(CGLGetCurrentContext());
        } // if
    } // if
    else
    {
        mbIsWaiting = NO;
        
        glClear(GL_COLOR_BUFFER_BIT);
        
        [self _drawScene];
        
        CGLFlushDrawable(CGLGetCurrentContext());
    } // else
    
    glFinish();
} // draw

- (void) resize:(NSRect)frame
{
    if((frame.size.width >= NBody::Window::kWidth) &&  (frame.size.height >= NBody::Window::kHeight))
    {
        const GLint nWidowWidth  = GLint(frame.size.width  + 0.5f);
        const GLint nWidowHeight = GLint(frame.size.height + 0.5f);
        
        _isResized = (nWidowWidth != mnWidowWidth) || (nWidowHeight != mnWidowHeight);
        
        mnWidowWidth  = nWidowWidth;
        mnWidowHeight = nWidowHeight;
        
        _size = frame.size;
        
        if(mpVisualizer != nullptr)
        {
            mpVisualizer->setFrame(_size);
        } // if
        
        [self _resizeButtons];
        [self _resizeMeters];
    } // if
} // resize

- (void) move:(CGPoint)point
{
    if(mbIsRotating)
    {
        m_Rotation.x += (point.x - m_MousePt.x) * 0.2f;
        m_Rotation.y += (point.y - m_MousePt.y) * 0.2f;
        
        mpVisualizer->setRotation(m_Rotation);
        
        m_MousePt.x = point.x;
        m_MousePt.y = point.y;
    } // if
} // move

- (void) click:(GLint)state
         point:(CGPoint)point
{
    CGPoint pos  = NSMakePoint(point.x, _size.height - point.y);
    CGFloat wmax = 0.75f * _size.width;
    CGFloat wmin = 0.5f * NBody::Button::kWidth;
    
    if (    (state == NBody::Mouse::Button::kDown)
        &&  (pos.y <= (2.0f * NBody::Button::kHeight))
        &&  (pos.x >= (wmax - wmin))
        &&  (pos.x <= (wmax + wmin)))
    {
        [self _swapSimulators];
    } // if
} // click

- (void) scroll:(GLfloat)delta
{
    mpVisualizer->setViewDistance(delta);
} // scroll

- (void) setActiveDemo:(GLuint)activeDemo
{
    [self _setDemo:activeDemo];
} // setActiveDemo

- (void) setClearColor:(GLfloat)clearColor
{
    _clearColor = clearColor;
    
    _preferences.clearColor = _clearColor;
} // setClearColor

- (void) setCommand:(unichar)command
{
    switch(command)
    {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        {
            // N-Body demo types
            [self _selectDemo:command];
            
            break;
        }
            
        case 'a':
        {
            [self _showMeters:YES];
            
            break;
        }
            
        case 'c':
        {
            [self _toggleMeter:NBody::eNBodyMeterCPU];
            
            break;
        }
            
        case 'd':
        {
            [mpButtons toggle];
            
            _preferences.showDock = mpButtons.isVisible;
            
            break;
        }
            
        case 'e':
        {
            mpVisualizer->toggleEarthView();
            
            break;
        }
            
        case 'f':
        {
            [self _toggleMeter:NBody::eNBodyMeterFrames];
            
            break;
        }
            
        case 'g':
        {
            [self _swapVisualizer];
            
            break;
        }
            
        case 'h':
        {
            [self _showMeters:NO];
            
            break;
        }
            
        case 'n':
        {
            [self _nextDemo];
            
            break;
        }
            
        case 'p':
        {
            [self _toggleMeter:NBody::eNBodyMeterPerf];
            
            break;
        }
            
        case 'r':
        {
            mpVisualizer->toggleRotation();
            
            break;
        }
            
        case 'R':
        {
            [self _restart];
            
            break;
        }
            
        case 's':
        {
            [self _swapSimulators];
            
            break;
        }
            
        case 'u':
        {
            [self _toggleMeter:NBody::eNBodyMeterUpdates];
            
            break;
        }
            
        case 'z':
        {
            [self _reset];
            
            break;
        }
            
        default:
            break;
    } // switch
    
    _command = command;
} // setCommand

- (void) setFrame:(NSRect)frame
{
    [self resize:frame];
} // setFrame

- (void) setViewDistance:(GLfloat)viewDistance
{
    _viewDistance = viewDistance;
    
    _preferences.viewDistance = _viewDistance;
} // setViewDistance

@end
