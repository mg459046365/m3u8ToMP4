# m3u8ToMP4
解析m3u8视频，并下载保存成mp4格式

该功能是基于FFmpeg实现的，由于FFmpeg相关代码比较大，所以对FFmpeg相关的代码进行了压缩，名为FFmpeg-iOS.zip。

使用时，需要将FFmpeg-iOS.zip解压并将解压后的文件夹引入项目即可。

1. 2020年2月10日更新：TSTOMP4.m文件中的方法runCmd跳转到ffmpeg_main方法中，在 `register_exit(ffmpeg_cleanup);`后面添加代码`ffmpeg_cleanup(0);`
    
