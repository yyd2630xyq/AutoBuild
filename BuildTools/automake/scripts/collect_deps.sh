#!/bin/sh

# Usage: collect_deps.sh <dep_file.d> <output_file.d.txt>
# Extracts included header paths from a .d dependency file and writes them to a .txt file


# 使用 Perl 正则模式 (-P), 从输入文件 $1 中提取符合以下格式的路径片段:
# 正则说明:
#   \S*              :匹配连续的非空白字符(代表路径前缀)
#   [\\/]            :匹配一个正斜杠 / 或反斜杠 \, 兼容 Windows/Linux 路径分隔符
#   (?=...)          :正向前瞻, 确保后面是指定格式但不包括在输出中
#     [^\\/\s]+      :文件名(不能包含斜杠, 反斜杠或空白, 且至少1个字符)
#     \.[hH]         :以 .h 或 .H 结尾
#     (?:\s+(?!:)|$) :其后要么是空白 + 非冒号字符(避免冒号左侧表示 target ), 要么是行尾($)
#
# 总体作用: 匹配以路径形式出现的 .h 或 .H 头文件路径(不包括文件名本身)
#          例如从 "src/util/mydir/file.h" 中提取 "src/util/mydir/"
# 如果 grep 失败(无匹配或出错), 则仍创建空输出文件 $2, 避免下游报错
#
# 系统环境的 locale 设置若不兼容 UTF-8 会导致无法使用 grep -P (export LC_ALL=C.UTF-8)
# grep -oP '\S*[\\/](?=[^\\/\s]+\.[hH](?:\s+(?!:)|$))' $1 > $2 || > $2


awk '
{
	for (i = 1; i <= NF; i++) {
		# 正则判断字段满足:
		# 1. 以 \/ 开始
		# 2. 至少1个非 \/ 字符(文件名部分)
		# 3. 以 .hH 结尾
		if ($i ~ /[\/\\][^\/\\]+\.[hH]$/) {
			# 若下个字段以冒号起始则跳过
			if ((i < NF) && ($(i+1) ~ /^:/)) {
				continue
			}
			# 提取路径部分
			sub(/[^\/\\]+\.[hH]$/, "", $i)
			print $i
		}
	}
}' $1 > $2
