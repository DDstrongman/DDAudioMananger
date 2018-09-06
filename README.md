# DDAudioManagerSpec


## Example
**类似SDWebImage的通过URL，在线播放并下载缓存音频工具类，请使用shareInstance实例化或定义Manager为全局变量:**<br>
**觉得好用请给star，不好用欢迎fork，push帮忙提升或是直接反馈，楼主尽快修复**
关键函数 <br>
```
/**
播放音频并按模式处理

@param url 音频url
@param method 音频播放模式
*/
- (void)playAudioWithUrl:(NSString *)url
                  Method:(DDAudioMethod)method 
```
**具体内容请参考.h文件内说明**

## Requirements

## Installation

DDAudioManage is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DDAudioManager"
```

## Author

DDStrongman, lishengshu232@gmail.com

## License

DDAudioManager is available under the MIT license. See the LICENSE file for more info.
