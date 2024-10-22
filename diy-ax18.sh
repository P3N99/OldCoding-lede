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
#rm -rf feeds/packages/lang/golang 
#rm -rf feeds/luci/applications/luci-app-pushbot feeds/luci/applications/luci-app-serverchan

# 下载插件
git clone --depth 1 https://github.com/gngpp/luci-theme-design package/luci-theme-design
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth 1 https://github.com/fw876/helloworld
git clone https://github.com/chenmozhijin/luci-app-adguardhome
# git clone https://github.com/sbwml/luci-app-alist package/luci-app-alist
# git clone https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages

# svn_export "main" "luci-app-passwall" "package/luci-app-passwall" "https://github.com/xiaorouji/openwrt-passwall"

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a

# 个性化设置
cd package
sed -i "s/OpenWrt /P3N9 build $(TZ=UTC-8 date "+%Y.%m.%d") @ Lean /g" lean/default-settings/files/zzz-default-settings
#sed -i 's/OpenWrt/E8820S/' package/base-files/files/bin/config_generate
#sed -i "/firewall\.user/d" lean/default-settings/files/zzz-default-settings
sed -i 's/192.168.1.1/192.168.3.1/g' base-files/files/bin/config_generate
