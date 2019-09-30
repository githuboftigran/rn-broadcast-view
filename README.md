# BroadcastView
A high quality react native component backed by custom native iOS and Android views.

<p align="center">
<img src="https://raw.githubusercontent.com/githuboftigran/rn-broadcast-view/master/demo_android.gif" width="200" height="200">
</p>

## Installation
1. Add

   * npm: `npm install --save rn-broadcast-view`
   * yarn: `yarn add rn-broadcast-view`

2. Linking

##### For older React native versions ( < 0.60 ) you need to link the library: 

   - Run `react-native link  rn-broadcast-view`
   - If linking fails, follow the
     [manual linking steps](https://facebook.github.io/react-native/docs/linking-libraries-ios.html#manual-linking)

##### For newer React native versions ( >= 0.60 ) you need to install pods for iOS:
   - cd ios && pod install && cd ..
   - For android everything works out of the box

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
