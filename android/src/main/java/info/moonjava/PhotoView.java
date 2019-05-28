package info.moonjava;

import android.content.Context;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.view.View;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.load.model.GlideUrl;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.facebook.drawee.backends.pipeline.PipelineDraweeControllerBuilder;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.events.EventDispatcher;

import me.relex.photodraweeview.OnPhotoTapListener;
import me.relex.photodraweeview.OnScaleChangeListener;
import me.relex.photodraweeview.OnViewTapListener;
import me.relex.photodraweeview.PhotoDraweeView;

/**
 * @author alwx (https://github.com/alwx)
 * @version 1.0
 */
public class PhotoView extends PhotoDraweeView implements RequestListener<Drawable> {
    public GlideUrl glideUrl;
    private PipelineDraweeControllerBuilder mDraweeControllerBuilder;

    public PhotoView(Context context) {
        super(context);
    }


    public void setFadeDuration(int durationMs) {
    }

    public void setShouldNotifyLoadEvents(boolean shouldNotify) {

    }

    public void maybeUpdateView(PipelineDraweeControllerBuilder builder) {
        if (builder != null) {
            GenericDraweeHierarchy hierarchy = getHierarchy();
            hierarchy.setFadeDuration(100);
            mDraweeControllerBuilder = builder;
            mDraweeControllerBuilder.setAutoPlayAnimations(true);
            mDraweeControllerBuilder.setOldController(getController());
            setController(mDraweeControllerBuilder.build());
            setViewCallbacks();
        }
    }

    private void setViewCallbacks() {
        final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class).getEventDispatcher();

        setOnPhotoTapListener(new OnPhotoTapListener() {
            @Override
            public void onPhotoTap(View view, float x, float y) {
                WritableMap scaleChange = Arguments.createMap();
                scaleChange.putDouble("x", x);
                scaleChange.putDouble("y", y);
                scaleChange.putDouble("scale", PhotoView.this.getScale());
                eventDispatcher.dispatchEvent(
                        new ImageEvent(getId(), ImageEvent.ON_TAP).setExtras(scaleChange)
                );
            }
        });

        setOnScaleChangeListener(new OnScaleChangeListener() {
            @Override
            public void onScaleChange(float scaleFactor, float focusX, float focusY) {
                WritableMap scaleChange = Arguments.createMap();
                scaleChange.putDouble("scale", PhotoView.this.getScale());
                scaleChange.putDouble("scaleFactor", scaleFactor);
                scaleChange.putDouble("focusX", focusX);
                scaleChange.putDouble("focusY", focusY);
                eventDispatcher.dispatchEvent(
                        new ImageEvent(getId(), ImageEvent.ON_SCALE).setExtras(scaleChange)
                );
            }
        });

        setOnViewTapListener(new OnViewTapListener() {
            @Override
            public void onViewTap(View view, float x, float y) {
                WritableMap scaleChange = Arguments.createMap();
                scaleChange.putDouble("x", x);
                scaleChange.putDouble("y", y);
                eventDispatcher.dispatchEvent(
                        new ImageEvent(getId(), ImageEvent.ON_VIEW_TAP).setExtras(scaleChange)
                );
            }
        });
    }

    @Override
    public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
        return false;
    }

    @Override
    public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
        final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class).getEventDispatcher();
        final int imageWidth = resource.getIntrinsicWidth();
        final int imageHeight = resource.getIntrinsicHeight();
        setEnableDraweeMatrix(true);
        eventDispatcher.dispatchEvent(
                new ImageEvent(getId(), ImageEvent.ON_LOAD)
        );
        eventDispatcher.dispatchEvent(
                new ImageEvent(getId(), ImageEvent.ON_LOAD_END)
        );
        update(imageWidth, imageHeight);
        return false;
    }
}

