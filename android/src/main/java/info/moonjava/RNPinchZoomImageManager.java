
package info.moonjava;

import android.app.Activity;
import android.content.Context;
import android.graphics.PorterDuff;
import android.os.Build;
import android.support.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestManager;
import com.bumptech.glide.load.model.GlideUrl;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

import javax.annotation.Nonnull;

import info.moonjava.cache.FastImageOkHttpProgressGlideModule;
import info.moonjava.cache.FastImageProgressListener;
import info.moonjava.cache.FastImageSource;
import info.moonjava.cache.FastImageViewConverter;

public class RNPinchZoomImageManager extends SimpleViewManager<PhotoView> implements FastImageProgressListener {

    private static final String REACT_CLASS = "RNPinchZoomImage";
    private static final String REACT_ON_LOAD_START_EVENT = "onFastImageLoadStart";
    private static final String REACT_ON_PROGRESS_EVENT = "onFastImageProgress";

    private static final Map<String, List<PhotoView>> VIEWS_FOR_URLS = new WeakHashMap<>();

    RNPinchZoomImageManager(ReactApplicationContext context) {
    }

    @javax.annotation.Nullable
    private RequestManager requestManager = null;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected PhotoView createViewInstance(ThemedReactContext reactContext) {
        if (isValidContextForGlide(reactContext)) {
            requestManager = Glide.with(reactContext);
        }
        return new PhotoView(reactContext);
    }

    @ReactProp(name = "src")
    public void setSource(PhotoView view, @Nullable ReadableMap source) {
        if (source == null || !source.hasKey("uri") || isNullOrEmpty(source.getString("uri"))) {
            // Cancel existing requests.
            if (requestManager != null) {
                requestManager.clear(view);
            }

            if (view.glideUrl != null) {
                FastImageOkHttpProgressGlideModule.forget(view.glideUrl.toStringUrl());
            }
            // Clear the image.
            view.setImageDrawable(null);
            return;
        }

        //final GlideUrl glideUrl = FastImageViewConverter.getGlideUrl(view.getContext(), source);
        final FastImageSource imageSource = FastImageViewConverter.getImageSource(view.getContext(), source);
        final GlideUrl glideUrl = imageSource.getGlideUrl();

        // Cancel existing request.
        view.glideUrl = glideUrl;
        if (requestManager != null) {
            requestManager.clear(view);
        }

        String key = glideUrl.toStringUrl();
        FastImageOkHttpProgressGlideModule.expect(key, this);
        List<PhotoView> viewsForKey = VIEWS_FOR_URLS.get(key);
        if (viewsForKey != null && !viewsForKey.contains(view)) {
            viewsForKey.add(view);
        } else if (viewsForKey == null) {
            List<PhotoView> newViewsForKeys = new ArrayList<>(Collections.singletonList(view));
            VIEWS_FOR_URLS.put(key, newViewsForKeys);
        }

        ThemedReactContext context = (ThemedReactContext) view.getContext();
        RCTEventEmitter eventEmitter = context.getJSModule(RCTEventEmitter.class);
        int viewId = view.getId();
        eventEmitter.receiveEvent(viewId, REACT_ON_LOAD_START_EVENT, new WritableNativeMap());

        if (requestManager != null) {
            view.setEnableDraweeMatrix(false);
            requestManager
                    // This will make this work for remote and local images. e.g.
                    //    - file:///
                    //    - content://
                    //    - res:/
                    //    - android.resource://
                    //    - data:image/png;base64
                    .load(imageSource.getSourceForLoad())
                    .apply(FastImageViewConverter.getOptions(source))
                    .listener(view)
                    .into(view);
        }
    }

    @ReactProp(name = "tintColor", customType = "Color")
    public void setTintColor(PhotoView view, @javax.annotation.Nullable Integer color) {
        if (color == null) {
            view.clearColorFilter();
        } else {
            view.setColorFilter(color, PorterDuff.Mode.SRC_IN);
        }
    }

    @ReactProp(name = "resizeMode")
    public void setResizeMode(PhotoView view, String resizeMode) {
        final PhotoView.ScaleType scaleType = FastImageViewConverter.getScaleType(resizeMode);
        view.setScaleType(scaleType);
    }

    @ReactProp(name = "loadingIndicatorSrc")
    public void setLoadingIndicatorSource(PhotoView view, @Nullable String source) {
    }

    @ReactProp(name = "fadeDuration")
    public void setFadeDuration(PhotoView view, int durationMs) {
        view.setFadeDuration(durationMs);
    }

    @ReactProp(name = "shouldNotifyLoadEvents")
    public void setLoadHandlersRegistered(PhotoView view, boolean shouldNotifyLoadEvents) {
        view.setShouldNotifyLoadEvents(shouldNotifyLoadEvents);
    }

    @ReactProp(name = "minimumZoomScale")
    public void setMinimumZoomScale(PhotoView view, float minimumZoomScale) {
        view.setMinimumScale(minimumZoomScale);
    }

    @ReactProp(name = "maximumZoomScale")
    public void setMaximumZoomScale(PhotoView view, float maximumZoomScale) {
        view.setMaximumScale(maximumZoomScale);
    }

    @ReactProp(name = "scale")
    public void setScale(PhotoView view, float scale) {
        view.setScale(scale, true);
    }

    @ReactProp(name = "androidZoomTransitionDuration")
    public void setScale(PhotoView view, int durationMs) {
        view.setZoomTransitionDuration(durationMs);
    }

    @ReactProp(name = "androidScaleType")
    public void setScaleType(PhotoView view, String scaleType) {
        ScalingUtils.ScaleType value = ScalingUtils.ScaleType.CENTER;

        switch (scaleType) {
            case "center":
                value = ScalingUtils.ScaleType.CENTER;
                break;
            case "centerCrop":
                value = ScalingUtils.ScaleType.CENTER_CROP;
                break;
            case "centerInside":
                value = ScalingUtils.ScaleType.CENTER_INSIDE;
                break;
            case "fitCenter":
                value = ScalingUtils.ScaleType.FIT_CENTER;
                break;
            case "fitStart":
                value = ScalingUtils.ScaleType.FIT_START;
                break;
            case "fitEnd":
                value = ScalingUtils.ScaleType.FIT_END;
                break;
            case "fitXY":
                value = ScalingUtils.ScaleType.FIT_XY;
                break;
        }
        GenericDraweeHierarchy hierarchy = view.getHierarchy();
        hierarchy.setActualImageScaleType(value);
    }

    @Override
    public @Nullable
    Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                ImageEvent.eventNameForType(ImageEvent.ON_LOAD_START), MapBuilder.of("registrationName", "onPhotoViewerLoadStart"),
                ImageEvent.eventNameForType(ImageEvent.ON_LOAD), MapBuilder.of("registrationName", "onPhotoViewerLoad"),
                ImageEvent.eventNameForType(ImageEvent.ON_LOAD_END), MapBuilder.of("registrationName", "onPhotoViewerLoadEnd"),
                ImageEvent.eventNameForType(ImageEvent.ON_TAP), MapBuilder.of("registrationName", "onPhotoViewerTap"),
                ImageEvent.eventNameForType(ImageEvent.ON_VIEW_TAP), MapBuilder.of("registrationName", "onPhotoViewerViewTap"),
                ImageEvent.eventNameForType(ImageEvent.ON_SCALE), MapBuilder.of("registrationName", "onPhotoViewerScale")
        );
    }

    @Override
    protected void onAfterUpdateTransaction(PhotoView view) {
        super.onAfterUpdateTransaction(view);
        view.maybeUpdateView(Fresco.newDraweeControllerBuilder());
    }

    private boolean isNullOrEmpty(final String url) {
        return url == null || url.trim().isEmpty();
    }

    @Override
    public void onProgress(String key, long bytesRead, long expectedLength) {
        List<PhotoView> viewsForKey = VIEWS_FOR_URLS.get(key);
        if (viewsForKey != null) {
            for (PhotoView view : viewsForKey) {
                WritableMap event = new WritableNativeMap();
                event.putInt("loaded", (int) bytesRead);
                event.putInt("total", (int) expectedLength);
                ThemedReactContext context = (ThemedReactContext) view.getContext();
                RCTEventEmitter eventEmitter = context.getJSModule(RCTEventEmitter.class);
                int viewId = view.getId();
                eventEmitter.receiveEvent(viewId, REACT_ON_PROGRESS_EVENT, event);
            }
        }
    }

    @Override
    public float getGranularityPercentage() {
        return 0.5f;
    }

    @Override
    public void onDropViewInstance(@Nonnull PhotoView view) {
        if (requestManager != null) {
            requestManager.clear(view);
        }
        if (view.glideUrl != null) {
            final String key = view.glideUrl.toString();
            FastImageOkHttpProgressGlideModule.forget(key);
            List<PhotoView> viewsForKey = VIEWS_FOR_URLS.get(key);
            if (viewsForKey != null) {
                viewsForKey.remove(view);
                if (viewsForKey.size() == 0) VIEWS_FOR_URLS.remove(key);
            }
        }
        super.onDropViewInstance(view);
    }

    private static boolean isValidContextForGlide(final Context context) {
        if (context == null) {
            return false;
        }
        if (context instanceof Activity) {
            final Activity activity = (Activity) context;
            if (isActivityDestroyed(activity)) {
                return false;
            }
        }

        if (context instanceof ThemedReactContext) {
            final Context baseContext = ((ThemedReactContext) context).getBaseContext();
            if (baseContext instanceof Activity) {
                final Activity baseActivity = (Activity) baseContext;
                return !isActivityDestroyed(baseActivity);
            }
        }

        return true;
    }

    private static boolean isActivityDestroyed(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return activity.isDestroyed() || activity.isFinishing();
        } else {
            return activity.isFinishing() || activity.isChangingConfigurations();
        }

    }

}