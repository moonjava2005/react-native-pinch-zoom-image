
# react-native-pinch-zoom-image

## Getting started

This module is based on [react-native-photo-view](https://github.com/alwx/react-native-photo-view). It seems "dead" adn we make some modifications to solve some problems

`$ npm install react-native-pinch-zoom-image --save`

Or

`$ yarn add react-native-pinch-zoom-image`

### Mostly automatic installation

`$ react-native link react-native-pinch-zoom-image`

### Manual installation


#### iOS

1. Add this line to your podfile
  pod `RNPinchZoomImage`, path: `../node_modules/react-native-pinch-zoom-image`
2. Run `pod install`

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import info.moonjava.RNPinchZoomLayoutPackage;` to the imports at the top of the file
  - Add `new RNPinchZoomLayoutPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-pinch-zoom-image'
  	project(':react-native-pinch-zoom-image').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-pinch-zoom-image/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      implementation project(':react-native-pinch-zoom-image')
  	```

## Dependencies
Install and link [react-native-fast-image](https://github.com/DylanVann/react-native-fast-image). To install and link it, run:
```
yarn add react-native-fast-image
react-native link react-native-fast-image
```

## Usage
```javascript
import React,{Component} from 'react';
import PinchZoomImage from 'react-native-pinch-zoom-image';
import {
    Image
} from 'react-native';

export default class ImageViewer extends Component {
    pinZoomLayoutRef=React.createRef();
    render() {
       return(<PinchZoomImage
                          style={{flex:1}}
                          ref={this.pinZoomLayoutRef}
                          onZoom={this.onZoom}
                          onTap={this.onTap}
                      >
                          <Image
                                style={{width:56,height:56}}
                                source={{
                                  uri:'https://facebook.github.io/react-native/img/header_logo.png'
                              }}
                          />
                      </PinchZoomImage>)
    }
    
    onZoom=event=>{
        const {
            containerWidth,
            containerHeight,
            contentWidth,
            contentHeight,
            zoomScale
        }=event;
    }
    
    onTap=()=>{
        
    }
}
```

### Configurable props
* [enabled](#enabled)
* [panEnabled](#panEnabled)
* [zoomDuration](#zoomDuration)
* [minimumZoomScale](#minimumZoomScale)
* [maximumZoomScale](#maximumZoomScale)

### Event props
* [onZoom](#onZoom)
* [onTap](#onTap)

### Methods
* [zoom](#zoom)


### Configurable props

#### enabled
Indicates whether the layout allows zoom.
* **true (default)** - allow zoom
* **false** -  Disable zoom

#### panEnabled
Indicates whether the layout can pan when the zoomed content is bigger than the container.
* **true (default)** - Allow pan
* **false** - Disable pan

#### zoomDuration
Animation duration of zoom.
* **default** - 400
Platforms: Android

#### minimumZoomScale
The minimum zoom level.
* **default** - 1

#### maximumZoomScale
The maximum zoom level.
* **default** - 3

#### onZoom
Callback function that is called when the view is zoomed. The event params is

```
const { 
  containerWidth,
  containerHeight,
  contentWidth,
  contentHeight,
  zoomScale
} = event;
```

#### onTap
Callback function that is called when the view is taped

#### zoom()
`zoom({zoomScale, animated})`

Zoom the content view to specific value.


Example:
```
this.pinZoomLayoutRef.current.zoom({zoomScale:2.5, animated:true}); // Zoom content view to 2.5 with animation
```