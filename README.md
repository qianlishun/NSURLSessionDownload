# NSURLSessionDownload
NSURLSession DownloaderManager

* 支持断点续传 : 暂停 和 暂停后退出程序的 断点续传
* 进度显示
* 下载完成后复制文件到桌面, 并删除沙盒缓存 (更改DownloaderManager.m 中 下载完成代理方法中的 caches 来更改下载完成保存位置)
* 修复了多次暂停和多次开始出现的小bug

