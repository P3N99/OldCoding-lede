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
git clone https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
# 下载插件
git clone https://github.com/gngpp/luci-theme-design package/luci-theme-design
# git clone https://github.com/sbwml/luci-app-alist package/luci-app-alist
# git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages
# git clone --depth 1 https://github.com/chenmozhijin/luci-app-adguardhome package/luci-app-adguardhome
# svn_export "main" "luci-app-passwall" "package/luci-app-passwall" "https://github.com/xiaorouji/openwrt-passwall"
# Add feed sources
echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

# 替换argon主题
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git ./feeds/luci/themes/luci-theme-argon
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f

# 个性化设置
cd package
sed -i "s/OpenWrt /P3N9 build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" lean/default-settings/files/zzz-default-settings
# sed -i 's/OpenWrt/E8820S/' package/base-files/files/bin/config_generate
sed -i "/firewall\.user/d" lean/default-settings/files/zzz-default-settings
sed -i 's/192.168.1.1/192.168.10.1/g' base-files/files/bin/config_generate

#AdguardHome
cd ./package/luci-app-adguardhome/root/usr
mkdir -p ./bin/AdGuardHome && cd ./bin/AdGuardHome
ADG_VER=$(curl -sfL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases 2>/dev/null | grep 'tag_name' | egrep -o "v[0-9].+[0-9.]" | awk 'NR==1')
curl -sfL -o /tmp/AdGuardHome_linux.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/download/${ADG_VER}/AdGuardHome_linux_mipsle_softfloat.tar.gz
tar -zxf /tmp/*.tar.gz -C /tmp/ && chmod +x /tmp/AdGuardHome/AdGuardHome
upx_latest_ver="$(curl -sfL https://api.github.com/repos/upx/upx/releases/latest 2>/dev/null | egrep 'tag_name' | egrep '[0-9.]+' -o 2>/dev/null)"
curl -sfL -o /tmp/upx-${upx_latest_ver}-amd64_linux.tar.xz "https://github.com/upx/upx/releases/download/v${upx_latest_ver}/upx-${upx_latest_ver}-amd64_linux.tar.xz"
xz -d -c /tmp/upx-${upx_latest_ver}-amd64_linux.tar.xz | tar -x -C "/tmp"
/tmp/upx-${upx_latest_ver}-amd64_linux/upx --ultra-brute /tmp/AdGuardHome/AdGuardHome > /dev/null 2>&1
mv /tmp/AdGuardHome/AdGuardHome ./ && rm -rf /tmp/AdGuardHome

cd $GITHUB_WORKSPACE/openwrt && cd feeds/luci/applications/luci-app-wrtbwmon
sed -i 's/ selected=\"selected\"//g' ./luasrc/view/wrtbwmon/wrtbwmon.htm && sed -i 's/\"1\"/\"1\" selected=\"selected\"/g' ./luasrc/view/wrtbwmon/wrtbwmon.htm
sed -i 's/interval: 5/interval: 1/g' ./htdocs/luci-static/wrtbwmon/wrtbwmon.js

