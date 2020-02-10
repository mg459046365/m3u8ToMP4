//
//  TS2MP4.m
//  M3U8TOMP4Demo
//
//  Created by Beryter on 2019/7/16.
//  Copyright © 2019 Beryter. All rights reserved.
//

#import "TS2MP4.h"
#import "ffmpeg.h"
#import <AVFoundation/AVFoundation.h>

@implementation TS2MP4

+ (NSError *)convertTS:(NSString *)tsPath toMP4:(NSString *)mp4Path {
    if (!tsPath || tsPath.length <= 0) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10000 userInfo:@{NSLocalizedDescriptionKey: @"TS文件路径错误"}];
    }
    if (!mp4Path || tsPath.length <= 0) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10001 userInfo:@{NSLocalizedDescriptionKey: @"输出文件路径错误"}];
    }
    if ([tsPath stringByReplacingOccurrencesOfString:@" " withString:@""].length <= 0) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10002 userInfo:@{NSLocalizedDescriptionKey: @"TS文件路径错误"}];
    }
    if ([mp4Path stringByReplacingOccurrencesOfString:@" " withString:@""].length <= 0) {
       return [NSError errorWithDomain:@"TS2MP4Domain" code:10003 userInfo:@{NSLocalizedDescriptionKey: @"输出文件路径错误"}];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:tsPath]) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10004 userInfo:@{NSLocalizedDescriptionKey: @"TS文件不存在"}];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:mp4Path]) {
        [[NSFileManager defaultManager] removeItemAtPath:mp4Path error:nil];
    }
    
    // ffmpeg语法，可根据需求自行更改
    // !#$ 为分割标记符，也可以使用空格代替
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg!#$-ss!#$00:00:00!#$-i!#$%@!#$-b:v!#$2000K!#$-y!#$%@", tsPath, mp4Path];//47s,太慢
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg!#$-y!#$-i!#$%@!#$-vcodec!#$copy!#$-acodec!#$copy!#$-vbsf!#$h264_mp4toannexb!#$%@", tsPath, mp4Path];
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg!#$-i!#$%@!#$-acodec!#$copy!#$-vcodec!#$copy!#$-f!#$mp4!#$%@", tsPath, mp4Path];
//    commandStr = [NSString stringWithFormat:@"ffmpeg!#$-i!#$%@!#$-c:v!#$copy!#$-c:a!#$libfdk_aac!#$%@", tsPath, mp4Path];
//    commandStr = [NSString stringWithFormat:@"ffmpeg!#$-i!#$%@!#$%@", tsPath, mp4Path];
//    commandStr = [NSString stringWithFormat:@"ffmpeg!#$-i!#$%@!#$-c:v!#$copy!#$-c:a!#$aac!#$%@", tsPath, mp4Path];
    int res =  [TS2MP4 runCmd:commandStr];
    if (res != 0) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10005 userInfo:@{NSLocalizedDescriptionKey: @"转换失败, 请检查TS文件"}];
    }
    if (![NSFileManager.defaultManager fileExistsAtPath:mp4Path]) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10006 userInfo:@{NSLocalizedDescriptionKey: @"转换失败, 请检查TS文件"}];
    }
    NSError *error = nil;
    NSDictionary *fileAttr = [NSFileManager.defaultManager attributesOfItemAtPath:mp4Path error:&error];
    if (error || !fileAttr) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10007 userInfo:@{NSLocalizedDescriptionKey: @"转换失败, 请检查TS文件"}];
    }
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:mp4Path] options:nil];
    if (CMTimeGetSeconds(asset.duration) <= 0 || asset.tracks.count <= 0) {
        return [NSError errorWithDomain:@"TS2MP4Domain" code:10008 userInfo:@{NSLocalizedDescriptionKey: @"转换失败, 请检查TS文件"}];
    }
    asset = nil;
    return nil;
}

// 执行指令
+ (int)runCmd:(NSString *)commandStr {
    // 根据 !#$ 将指令分割为指令数组
    NSArray *argv_array = [commandStr componentsSeparatedByString:(@"!#$")];
    // 将OC对象转换为对应的C对象
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*)*argc);
    for(int i=0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    // 打印日志
    NSString *finalCommand = @"ffmpeg 运行参数:";
    for (NSString *temp in argv_array) {
        finalCommand = [finalCommand stringByAppendingFormat:@"%@",temp];
    }
    NSLog(@"%@",finalCommand);
    // 传入指令数及指令数组
    int res = ffmpeg_main(argc,argv);
    // 线程已杀死,下方的代码不会执行
    return res;
}

@end
