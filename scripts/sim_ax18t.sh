#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# 删除冲突软件和依赖
rm -rf feeds/packages/lang/golang 
git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

#git clone --depth 1 https://github.com/chenmozhijin/luci-app-adguardhome package/luci-app-adguardhome

cd package
sed -i "s/OpenWrt /P3N9 build $(TZ=UTC-8 date "+%Y.%m.%d") @LEDE/g" lean/default-settings/files/zzz-default-settings
sed -i 's/192.168.1.1/192.168.3.1/g' base-files/files/bin/config_generate

# 替换argon主题
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
