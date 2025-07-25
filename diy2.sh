#!/bin/bash
svn_export() {
	# 参数1是分支名, 参数2是子目录, 参数3是目标目录, 参数4仓库地址
	TMP_DIR="$(mktemp -d)" || exit 1
 	ORI_DIR="$PWD"
	[ -d "$3" ] || mkdir -p "$3"
	TGT_DIR="$(cd "$3"; pwd)"
	git clone --depth 1 -b "$1" "$4" "$TMP_DIR" >/dev/null 2>&1 && \
	cd "$TMP_DIR/$2" && rm -rf .git >/dev/null 2>&1 && \
	cp -af . "$TGT_DIR/" && cd "$ORI_DIR"
	rm -rf "$TMP_DIR"
}


# 删除冲突软件和依赖
rm -rf feeds/packages/lang/golang 
rm -rf feeds/luci/applications/luci-app-filebrowser
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-design/root/etc/uci-defaults/30_luci-theme-design
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
git clone --depth 1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
# 下载插件
git clone --depth 1 https://github.com/fw876/helloworld package/helloworld
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth 1 https://github.com/OldCoding/luci-app-filebrowser package/luci-app-filebrowser

# 编译 po2lmo (如果有po2lmo可跳过)
#pushd package/luci-app-openclash/tools/po2lmo
#make && sudo make install
#popd

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a

# 调整菜单位置
sed -i "s|services|system|g" feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i "s|services|network|g" feeds/luci/applications/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json

# 个性化设置
cd package
sed -i "s/LEDE /P3NG build $(TZ=UTC-8 date "+%Y.%m.%d") @ LEDE /g" lean/default-settings/files/zzz-default-settings
sed -i "s/LEDE/ETR631/" base-files/luci2/bin/config_generate
sed -i "/ntp/d" lean/default-settings/files/zzz-default-settings
sed -i "/firewall\.user/d" lean/default-settings/files/zzz-default-settings
sed -i "s/192.168.1.1/192.168.10.1/g" base-files/luci2/bin/config_generate
sed -i "/openwrt_luci/d" lean/default-settings/files/zzz-default-settings
sed -i "s/encryption='.*'/encryption='sae-mixed'/g" kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i "s/country='.*'/country='CN'/g" kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '186i \\t\t\tset wireless.default_radio${devidx}.key=123456789' kernel/mac80211/files/lib/wifi/mac80211.sh
