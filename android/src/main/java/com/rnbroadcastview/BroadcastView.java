package com.ashideas.rnbroadcastview;

import android.annotation.TargetApi;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Build;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewCompat;
import android.util.AttributeSet;
import android.view.View;

import java.util.ArrayList;
import java.util.List;

public class BroadcastView extends View {

    private static final long WAVE_TIME = 3 * 1000; // 3 seconds
    private static final long WAVE_DIFF = WAVE_TIME / 4;

    private static final int DEFAULT_STATION_COLOR = 0xff4286f4;
    private static final int DEFAULT_WAVE_COLOR = 0xffff60ad;
    private static final float LINE_WIDTH_RELATIVE_TO_PARENT = 0.05f;

    private Paint stationPaint;
    private Paint wavePaint;
    private List<Long> timeQueue;
    private Handler handler;
    private Runnable addTime;

    private boolean broadCasting;
    private int stationColor;
    private int waveColor;

    public BroadcastView(Context context) {
        super(context);
        init();
    }

    public BroadcastView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public BroadcastView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    public BroadcastView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {

        setClickable(true);
        stationPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        stationPaint.setStyle(Paint.Style.FILL);
        stationPaint.setStrokeCap(Paint.Cap.ROUND);

        wavePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        wavePaint.setStyle(Paint.Style.STROKE);

        broadCasting = false;

        setStationColor(DEFAULT_STATION_COLOR);
        setWaveColor(DEFAULT_WAVE_COLOR);
        timeQueue = new ArrayList<>();
        handler = new Handler();
        addTime = new AddTime();
    }

    public void setStationColor(int stationColor) {
        this.stationColor = stationColor;
    }

    public void setWaveColor(int waveColor) {
        this.waveColor = waveColor;
        this.wavePaint.setColor(waveColor);
    }

    public void setBroadCasting(boolean broadCasting) {
        if (this.broadCasting == broadCasting) {
            return;
        }
        this.broadCasting = broadCasting;
        if (!broadCasting) {
            handler.removeCallbacks(addTime);
            ViewCompat.postInvalidateOnAnimation(this);
            return;
        }

        long postDelay = 0;
        long currentMillis = System.currentTimeMillis();
        boolean isFirst = timeQueue.isEmpty();
        if (!isFirst) {
            long lastQueued = timeQueue.get(timeQueue.size() - 1);
            if (lastQueued > currentMillis) { // Next one is already queued
                return;
            }
            long diff = currentMillis - lastQueued;
            if (diff < WAVE_DIFF) {
                postDelay = WAVE_DIFF - diff;
            }
        }
        handler.postDelayed(addTime, postDelay);
        if (isFirst) {
            invalidate();
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        stationPaint.setStrokeWidth(Math.min(getMeasuredWidth(), getMeasuredHeight()) * LINE_WIDTH_RELATIVE_TO_PARENT);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        float cx = getWidth() / 2;
        float cy = getHeight() / 2;
        float r = Math.min(cx, cy);
        float transmitterRadius = r / 8;

        float stationWidth = stationPaint.getStrokeWidth();
        stationPaint.setColor(stationColor);

        canvas.drawLine(cx - r / 4, cy + r - stationWidth, cx, cy, stationPaint);
        canvas.drawLine(cx + r / 4, cy + r - stationWidth, cx, cy, stationPaint);

        canvas.drawLine(cx - r / 4, cy + r - stationWidth, cx + r / 8, cy + r / 2, stationPaint);
        canvas.drawLine(cx + r / 4, cy + r - stationWidth, cx - r / 8, cy + r / 2, stationPaint);

        if (broadCasting) {
            stationPaint.setColor(waveColor);
        }
        canvas.drawCircle(cx, cy, transmitterRadius, stationPaint);

        long now = System.currentTimeMillis();
        for (int i = 0; i < timeQueue.size(); i++) {
            long diff = now - timeQueue.get(i);
            if (diff >= WAVE_TIME) {
                timeQueue.remove(i);
                i--;
            } else if (diff > 0) {
                float fraction = 1 - diff / (float) WAVE_TIME;
                wavePaint.setStrokeWidth(stationWidth * fraction * fraction);
                float startRadius = transmitterRadius - stationWidth / 2;
                canvas.drawCircle(cx, cy, startRadius + (r - startRadius) * diff / WAVE_TIME, wavePaint);
            }
        }

        if (!timeQueue.isEmpty()) {
            ViewCompat.postInvalidateOnAnimation(this);
        }
    }

    private class AddTime implements Runnable {
        @Override
        public void run() {
            if (broadCasting) {
                timeQueue.add(System.currentTimeMillis());
                handler.postDelayed(this, WAVE_DIFF);
                ViewCompat.postInvalidateOnAnimation(BroadcastView.this);
            }
        }
    }
}
