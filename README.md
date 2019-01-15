# BroadcastView
A high quality react native component backed by custom native iOS and Android views.

<p align="center">
<img src="/demo_android.gif" width="200" height="200">
</p>

## Installation
1. Add

   * npm: `npm install --save rn-broadcast-view`
   * yarn: `yarn add rn-broadcast-view`

2. Link
   - Run `react-native link  rn-broadcast-view`
   - If linking fails, follow the
     [manual linking steps](https://facebook.github.io/react-native/docs/linking-libraries-ios.html#manual-linking)


## Usage

```BroadcastView``` should have fixed width and height.

```
import BroadcastView from 'rn-broadcast-view';

...

<BroadcastView style={{width: 100, height: 100}} />

...
```

#### Properties

| Property |      Description      | Type | Default Value |
|----------|-----------------------|------|:-------------:|
| broadcasting | An infinite "broadcast wave" animation is shown if true | Boolean | **false** |
| stationColor |  Color of station | String<br/>(**#RRGGBB** or **#AARRGGBB**) | **#4286f4** |
| waveColor |  Color of waves | String<br/>(**#RRGGBB** or **#AARRGGBB**) | **#ff60ad** |
