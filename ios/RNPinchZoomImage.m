#import "RNPinchZoomImage.h"
#import "RNPhotoView.h"
#import "FFFastImageSource.h"

@implementation RNPinchZoomImage

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[RNPhotoView alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(source, FFFastImageSource)
RCT_EXPORT_VIEW_PROPERTY(loadingIndicatorSrc, NSString)

RCT_REMAP_VIEW_PROPERTY(maximumZoomScale, maxZoomScale, CGFloat)
RCT_REMAP_VIEW_PROPERTY(minimumZoomScale, minZoomScale, CGFloat)

RCT_EXPORT_VIEW_PROPERTY(showsHorizontalScrollIndicator, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsVerticalScrollIndicator, BOOL)

RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerScale, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerViewTap, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerTap, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerLoadStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerLoadEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPhotoViewerProgress, RCTDirectEventBlock);

@end
