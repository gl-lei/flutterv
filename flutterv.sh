#! /usr/bin/env bash
# 使用国内镜像
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 默认环境配置
default_flutter_download_sdk_dir=`echo $HOME`
default_flutter_platform="macos"
default_flutter_version="1.9.1+hotfix.6"
default_flutter_channel="stable"

# 配置文件路径以及配置变量
flutter_config_path="flutterv.properties"
flutter_download_sdk_dir=${default_flutter_download_sdk_dir}
flutter_platform=${default_flutter_platform}
flutter_version=${default_flutter_version}
flutter_channel=${default_flutter_channel}

# 读取配置文件中的配置
# echo "========================获取 flutter 配置文件的配置========================"
if test -e $flutter_config_path
then
    for line in `grep -v '^\s*#' $flutter_config_path`
    do
        array=(${line//=/ })
        config_name=${array[0]}
        config_value=${array[1]}
        if [ -z ${config_value} ]; then
            continue
        fi

        # echo "${config_name} ${config_value}"
        # 匹配配置
        case ${config_name} in
        "flutter_download_sdk_dir")
            flutter_download_sdk_dir="${config_value}"
            ;;
        "flutter_platform")
            flutter_platform="${config_value}"
            ;;
        "flutter_version")
            flutter_version="${config_value}"
            ;;
        "flutter_channel")
            flutter_channel="${config_value}"
            ;;
        *)
            echo "${config_name} 选项暂未使用！"
            ;;
        esac
    done < $flutter_config_path
else
    echo 'flutter-config.properties配置文件不存在，使用默认配置'
fi

# 输出 Flutter 配置
echo "========================输出 Flutter 的配置========================"
echo "Flutter 配置文件目录：$PWD/${flutter_config_path}"
echo "Flutter SDK存储目录：${flutter_download_sdk_dir}"
echo "Flutter 平台：${flutter_platform}"
echo "Flutter 版本：${flutter_version}, 通道：${flutter_channel}"

echo "========================检测是否下载 Flutter SDK压缩包========================"
# 判断本地是否存在Flutter SDK目录,不存在则创建
if [ ! -d $flutter_download_sdk_dir ]; then
    echo "创建 $flutter_download_sdk_dir 目录"
    mkdir -p $flutter_download_sdk_dir
fi

# 适配 linux
flutter_file_extension="zip"
if [ $flutter_platform == "linux" ]; then
    flutter_file_extension="tar.xz"
fi

# 下载 Flutter SDK 压缩包并解压
cur_dir=$PWD
sdk_zip_flie_name="flutter_${flutter_platform}_v${flutter_version}-${flutter_channel}.${flutter_file_extension}"
flutter_download_storage_url="${FLUTTER_STORAGE_BASE_URL}/flutter_infra/releases/${flutter_channel}/${flutter_platform}/${sdk_zip_flie_name}"
flutter_command="$flutter_download_sdk_dir/flutter/bin/flutter"
if [ ! -r $flutter_command ]; then
    echo "Flutter SDK 下载地址为: ${flutter_download_storage_url}"
    echo "开始下载 Flutter SDK ..."
    if [ ! -e $sdk_zip_flie_name ]; then
        curl -O ${flutter_download_storage_url}
    fi

    if [[ 0 == $? ]]; then
        echo "Flutter SDK 文件下载成功，解压中..."
        tar -zxf $sdk_zip_flie_name -C $flutter_download_sdk_dir || (echo "Flutter SDK 解压失败";exit -1)
        # rm -rf $sdk_zip_flie_name
        cd "${flutter_download_sdk_dir}/flutter"
        git checkout .
        cd $cur_dir
        echo "执行 flutter doctor -v 耗时可能很长, 请耐心等待..."
        $flutter_command doctor -v
    else
        echo "Flutter SDK 文件下载失败..."
        exit -1
    fi
fi

echo "========================检查本地版本与配置版本是否一致========================"
cur_flutter_version=`$flutter_command --version | grep '^Flutter' | cut -d ' ' -f2`
if [ $cur_flutter_version == $flutter_version ]; then
    $flutter_command $*
else
    echo "版本不一致, 当前版本为${cur_flutter_version}, 切换版本为: ${flutter_version}"
    cd "${flutter_download_sdk_dir}/flutter"
    git checkout .
    cd $cur_dir
    $flutter_command channel $flutter_channel
    $flutter_command upgrade
    $flutter_command version -f "v${flutter_version}"
    $flutter_command doctor -v
    cur_flutter_version=`$flutter_command --version | grep '^Flutter' | cut -d ' ' -f2`
    if [ $cur_flutter_version == $flutter_version ]; then
        echo "切换版本成功"
        $flutter_command $*
    else
        echo "切换版本失败"
    fi
fi