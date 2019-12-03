# flutterv
Flutter 版本统一脚本

### 前言
目前 Flutter 作为移动端比较火热的跨平台框架，越来越多的团队开始在项目中接入并且使用。由于 Flutter 框架更新速度很快（目前稳定版本为 1.9.1+hotfix.6），为了解决团队使用 Flutter 框架版本统一的问题，故编写此 Flutter 版本统一脚本。

### 脚本配置文件简介
项目中存在有两个文件：`flutterv.sh`、`flutterv.properties`，`flutterv.sh`为脚本文件，`flutterv.properties` 为脚本配置文件。在 `flutterv.sh` 脚本在运行的时候会读取`flutterv.properties` 配置文件中的配置项，没有指定配置的话，则使用默认配置。`flutterv.properties` 中的配置总共有五项：
- flutter_download_sdk_dir: Flutter SDK 存储目录；
- flutter_platform：Flutter 平台，目前只支持 `mac` 和 `linux`，`windows` 系统下需要使用bat脚本执行；
- flutter_version：Flutter 版本，需要按照标准格式来书写，比如：`1.9.1+hotfix.6`；
- flutter_channel：Flutter 通道，包含 `master` `dev` `beta` `stable`；
- need_reset_sdk：是否需要重置 sdk，如果为Y（y）,则在升级版本的时候删掉旧库，重新下载新 sdk，建议在版本升级跨度较大时使用；

### 脚本内容简介
- 脚本首先会读取配置文件中的配置，如果未配置的话则使用默认配置
- 检查 `flutter` 命令是否存在，不存在则下载配置的 flutter sdk
- 存在则检测当前 flutter 版本是否与配置版本一致，不一致则切换到指定的版本

### 使用介绍
可以作为单独统一脚本使用，也可以作为替代 `flutter` 命令使用

```
sh flutterv.sh --version
sh flutterv.sh doctor -v
```