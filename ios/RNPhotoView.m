#import "RNPhotoView.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTImageSource.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
#import <React/RCTImageLoader.h>

@interface RNPhotoView()

#pragma mark - View

@property (nonatomic, strong) MWTapDetectingImageView *photoImageView;
@property (nonatomic, strong) MWTapDetectingView *tapView;

#pragma mark - Data

@property (nonatomic, strong) UIImage *loadingImage;

@end

@implementation RNPhotoView
{
    __weak RCTBridge *_bridge;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if ((self = [super init])) {
        _bridge = bridge;
        [self initView];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleDoubleTap:(CGPoint)touchPoint {
    // Zoom
    CGSize boundSize=self.bounds.size;
    if(boundSize.width==0||boundSize.height==0)
    {
        return;
    }
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = ((_maxZoomScale + _minZoomScale) / 2);
        CGFloat currentBoundWidth=boundSize.width;
        CGFloat currentBoundHeight=boundSize.height;
        CGFloat xsize = currentBoundWidth / newZoomScale;
        CGFloat ysize = currentBoundHeight / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

#pragma mark - MWTapDetectingImageViewDelegate

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:imageView].x;
    CGFloat touchY = [touch locationInView:imageView].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    
    if (_onPhotoViewerTap) {
        _onPhotoViewerTap(@{
                            @"point": @{
                                    @"x": @(touchX),
                                    @"y": @(touchY),
                                    },
                            @"target": self.reactTag
                            });
    }
}

- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

#pragma mark - MWTapDetectingViewDelegate

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    
    if (_onPhotoViewerViewTap) {
        _onPhotoViewerViewTap(@{
                                @"point": @{
                                        @"x": @(touchX),
                                        @"y": @(touchY),
                                        },
                                @"target": self.reactTag,
                                });
    }
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundSize = self.bounds.size;
        if(boundSize.width==0||boundSize.height==0)
        {
            return  _minZoomScale;
        }
        CGSize imageSize = _photoImageView.image.size;
        //        CGFloat boundRatio = boundSize.width / boundSize.height;
        //        CGFloat imageRatio = imageSize.width / imageSize.height;
        CGFloat xScale = boundSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        
        zoomScale = MIN(xScale, yScale);
        // Ensure we don't zoom in or out too far, just in case
        zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        
    }
    return zoomScale;
    //  return 0.5;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    CGSize boundsSize = self.bounds.size;
    if (_photoImageView.image == nil||boundsSize.width==0||boundsSize.height==0) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize imageSize = _photoImageView.image.size;
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    /**
     [attention]
     original maximumZoomScale and minimumZoomScale is scaled to image,
     but we need scaled to scrollView,
     so has the next convert
     */
    CGFloat maxScale = minScale * _maxZoomScale;
    minScale = minScale * _minZoomScale;
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    // Initial zoom
    CGFloat _initMinZoomScale=[self initialZoomScaleWithMinScale];
    self.zoomScale = _initMinZoomScale;
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        
    }
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;
    
    // Layout
    [self setNeedsLayout];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    // Update tap view frame
    _tapView.frame = self.bounds;
    
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    if(frameToCenter.size.width==0)
    {
        frameToCenter.size.width=boundsSize.width;
    }
    if(frameToCenter.size.height==0)
    {
        frameToCenter.size.height=boundsSize.height;
    }
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
    {
        _photoImageView.frame = frameToCenter;
    }
    //If zoom to min, not allow scroll
    if(self.zoomScale <= self.minimumZoomScale)
    {
        self.scrollEnabled=NO;
    }
    else{
        self.scrollEnabled=YES;
    }
    if (_onPhotoViewerScale) {
        _onPhotoViewerScale(@{
                              @"scale": @(self.zoomScale),
                              @"target": self.reactTag
                              });
    }
}

#pragma mark - Setter

- (void)setSource:(FFFastImageSource *)source {
    [_photoImageView setSource:source];
}

- (void)setScale:(NSInteger)scale {
    _scale = scale;
    [self setZoomScale:_scale];
}

#pragma mark - Private

- (void)initView {
    _minZoomScale = 1.0;
    _maxZoomScale = 3.0;
    
    // Setup
    //    self.backgroundColor = [UIColor redColor];
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    }
    
    // Tap view for background
    _tapView = [[MWTapDetectingView alloc] initWithFrame:self.bounds];
    _tapView.tapDelegate = self;
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tapView.backgroundColor = [UIColor clearColor];
    [self addSubview:_tapView];
    
    // Image view
    _photoImageView = [[MWTapDetectingImageView alloc] init];
    CGRect _photoFrame= CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _photoImageView.frame=_photoFrame;
    //    _photoImageView.backgroundColor = [UIColor greenColor];
    _photoImageView.backgroundColor = [UIColor clearColor];
    __block RNPhotoView * blockSelf=self;
    [_photoImageView setOnFastImageLoad:^(NSDictionary *body){
        [blockSelf onImageLoaded:body];
    }];
    
    [_photoImageView setResizeMode:RCTResizeModeContain];
    _photoImageView.tapDelegate = self;
    [self addSubview:_photoImageView];
}

- (void)setOnPhotoViewerLoadStart:(RCTDirectEventBlock)onPhotoViewerLoadStart
{
    if(_photoImageView!=nil)
    {
        [_photoImageView setOnFastImageLoadStart:onPhotoViewerLoadStart];
    }
}
- (void)setOnPhotoViewerLoadEnd:(RCTDirectEventBlock)onPhotoViewerLoadEnd
{
    if(_photoImageView!=nil)
    {
        [_photoImageView setOnFastImageLoadEnd:onPhotoViewerLoadEnd];
    }
}
- (void)setOnPhotoViewerProgress:(RCTDirectEventBlock)onPhotoViewerProgress
{
    if(_photoImageView!=nil)
    {
        [_photoImageView setOnFastImageProgress:onPhotoViewerProgress];
    }
}

- (void) onImageLoaded:(NSDictionary*)body
{
    UIImage *image=_photoImageView.image;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = image.size;
    _photoImageView.frame = photoImageViewFrame;
    self.contentSize = photoImageViewFrame.size;
    
    // Set zoom to minimum zoom
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setNeedsLayout];
    if(_onPhotoViewerLoad)
    {
        _onPhotoViewerLoad(body);
    }
}

- (void)setAutoAdjustContentInset:(BOOL)autoAdjustContentInset
{
    if(autoAdjustContentInset)
    {
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentAutomatic;
        }
    }
    else{
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
        }
    }
    _autoAdjustContentInset=autoAdjustContentInset;
}

- (void)reactSetFrame:(CGRect)frame
{
    [super reactSetFrame:frame];
    [self setMaxMinZoomScalesForCurrentBounds];
    [self layoutIfNeeded];
}

- (void)didSetProps:(NSArray<NSString *> *)changedProps
{
    if (_photoImageView!=nil) {
        [_photoImageView didSetProps:changedProps];
    }
}

@end
