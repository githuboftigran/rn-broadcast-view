package com.ashideas.rnbroadcastview;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

public class BroadcastViewManager extends SimpleViewManager<BroadcastView> {

    private static final String REACT_CLASS = "BroadcastView";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactProp(name = "stationColor")
    public void setStationColor(BroadcastView view, String stationColor) {
        view.setStationColor(stationColor);
    }

    @ReactProp(name = "waveColor")
    public void setWaveColor(BroadcastView view, String waveColor) {
        view.setWaveColor(waveColor);
    }

    @ReactProp(name = "broadcasting")
    public void setBroadCasting(BroadcastView view, boolean broadcasting) {
        view.setBroadcasting(broadcasting);
    }

    @Override
    protected BroadcastView createViewInstance(ThemedReactContext reactContext) {
        return new BroadcastView(reactContext);
    }
}
