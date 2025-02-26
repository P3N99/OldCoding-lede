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
git clone --depth 1 https://github.com/fw876/helloworld package/helloworld
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall-packages
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth 1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth=1 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge

# 安装插件
./scripts/feeds update -i
./scripts/feeds install -a
set -x

# 个性化设置
cd package
sed -i "s/LEDE /P3N9 build $(TZ=UTC-8 date "+%Y.%m.%d") @ Lean /g" lean/default-settings/files/zzz-default-settings
sed -i 's/LEDE/ZN-M2/' package/base-files/files/bin/config_generate
sed -i "/firewall\.user/d" lean/default-settings/files/zzz-default-settings
sed -i 's/192.168.1.1/192.168.3.1/g' base-files/files/bin/config_generate
