# UICVideoPlayerView
Video player with play, pause, forward, rewind, seek, mute functionalities for IOS

## Screen shot (.gif)
<img src="https://github.com/Coder-ACJHP/UICVideoPlayerView/blob/master/videoPlayer.gif" width=274 height="584">

## How to use?
1 - Download `UICVideoPlayerView.swift` file (inside UICVideoPlayer folder) with it's assets (inside Assets.xcassets folder) and import it into your project. (Single .swift file and assests "icons")<br>
2 - Allow your application to support arbitrary loads from `info.plist`to allow `http` requests<br>
3 - Setup `UICVideoPlayerView` and add it to your view

### Code exmple: 
```
private var videoPlayer: UICVideoPlayerView!

let calculatedHeight = self.view.frame.width * 9 / 16
let videoLayerFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: calculatedHeight)
videoPlayer = UICVideoPlayerView(frame: videoLayerFrame)
videoPlayer.videoLink = sampleVideoLink
videoPlayer.delegate = self
view.addSubview(videoPlayer)

// Delegate method :
func dismiss(_ videoView: UICVideoPlayerView) {
// Dismiss videoPlayer view here or what ever you want
}
```
Note: For more information browse example project (DummyViewController)

No need to any other thing, so it's features like :
- When the video fail to load it shows error message.
- It shows streaming progress
- When video load will start to play.
- Shows replay button when video finished and resets slider.
- When changing video link it will prepare and update itself immediatly.
- Shows loading spinner depended on buffer status.
- You can share video link to social media and other chanels (new).
- You can change settings from settings context menu (new).<br>
###### Note: This project is sample so only "dismiss & cancel" option is working in menu others not!

### Requirements
Xcode 9 or later <br>
iOS 10.0 or later <br>
Swift 4 or later <br>

### Next update will add :
1 - Support play list of videos.<br>
2 - Next and previous buttons.<br>
3 - Support landscape mode.

### Licence :
The MIT License (MIT)
