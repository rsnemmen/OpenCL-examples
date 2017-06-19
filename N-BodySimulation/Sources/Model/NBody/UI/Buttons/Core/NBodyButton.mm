/*
 <codex>
 <import>NBodyButton.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import "GLMConstants.h"
#import "HUDButton.h"
#import "NBodyConstants.h"
#import "NBodyButton.h"

@implementation NBodyButton
{
@private
    BOOL         _isVisible;
    BOOL         _isSelected;
    BOOL         _isItalic;
    CGFloat      _fontSize;
    GLfloat      _speed;
    CGRect       _bounds;
    CGPoint      _position;
    CGPoint      _origin;
    CGSize       _size;
    std::string  _label;
    
    HUD::Button::Image* mpButton;
}

- (instancetype) init
{
    self = [super init];
    
    if(self)
    {
        mpButton    = nullptr;
        _label      = "";
        _isVisible  = YES;
        _isSelected = NO;
        _isItalic   = NO;
        _fontSize   = 24.0f;
        _bounds     = NSMakeRect(0.0f, 0.0f, 0.0f, 0.0f);
        _size       = NSMakeSize(0.0f, 0.0f);
        _position   = NSMakePoint(0.0f, 0.0f);
        _origin     = CGPointMake(0.0f, (_isVisible ? GLM::kHalfPi_f : 0.0f));
        _speed      = NBody::Defaults::kSpeed;
    } // if
    
    return self;
} // init

+ (instancetype) button
{
    return [[[NBodyButton allocWithZone:[self zone]] init] autorelease];
} // button

- (void) dealloc
{
    if(!_label.empty())
    {
        _label.clear();
    } // if
    
    if(mpButton != nullptr)
    {
        delete mpButton;
        
        mpButton = nullptr;
    } // if
    
    [super dealloc];
} // dealloc

- (void) setIsVisible:(BOOL)isVisible
{
    _isVisible = isVisible;
    _origin.y  = _isVisible ? GLM::kHalfPi_f : 0.0f;
} // setIsVisible

- (void) setLabel:(std::string)label
{
    if(!label.empty())
    {
        _label = label;
    } // if
} // setLabel

- (void) setSize:(CGSize)size
{
    _size   = size;
    _bounds = CGRectMake(0.75f * _size.width - 0.5f * NBody::Button::kWidth,
                         NBody::Button::kSpacing,
                         NBody::Button::kWidth,
                         NBody::Button::kHeight);
} // setSize

- (BOOL) acquire
{
    if(mpButton == nullptr)
    {
        mpButton = new (std::nothrow) HUD::Button::Image(_bounds,
                                                         _fontSize,
                                                         _isItalic,
                                                         _label);
    } // if
    
    return mpButton != nullptr;
} // acquire

- (void) toggle
{
    _isVisible = !_isVisible;
} // toggle

- (void) draw
{
    if(mpButton != nullptr)
    {
        if(_isVisible)
        {
            if(_origin.y <= (GLM::kHalfPi_f - _speed))
            {
                _origin.y += _speed;
            } // if
        } // if
        else if(_origin.y > 0.0f)
        {
            _origin.y -= _speed;
        } // else if
        
        GLfloat x = -NBody::Button::kWidth * std::sin(_origin.x);
        GLfloat y = 100.0f * (std::sin(_origin.y) - 1.0f);
        
        _position = CGPointMake(x, y);
        
        mpButton->draw(_isSelected, _position, _bounds);
    } // if
} // draw

@end
