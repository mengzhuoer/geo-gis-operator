# -*- coding: utf-8 -*-
"""规范化 AutoCAD 测量工具集 LISP 的中文编码，使其可被 AutoCAD 正确加载。

背景：仓库 `Qin-Dong/Construction-Surveying-Toolkit-For-AutoCAD` 的 .lsp 文件是
**GBK/GB18030 编码**（权威 blob 大小 41215 字节，sha256 940c64a3…）。按 GB18030 解码
中文完全可读（"功能：生成地形图方格网数据文件"等 1380 个汉字）；按 UTF-8 直读则得到
乱码（仅 16 个可识别汉字）。

AutoCAD 在简体中文 Windows 上按 ANSI 代码页（GBK）读取 LISP，因此**原文件其实可以直接
加载**——问题出在用 UTF-8 读写它的人身上。本脚本做两件事：

1. **诊断**：判断输入到底是「GBK 原文」还是「双重 mojibake」，并报告汉字可读数量；
2. **规范化**：无论哪种情况，都输出为 **GB18030 字节**，AutoCAD 可直接 APPLOAD / load。

用法：
    python fix_cad_lsp_mojibake.py <源.lsp> [输出.lsp]

不做任何猜测式转码——先测量，再决定。
"""
import re
import sys

CJK = re.compile(r'[\u4e00-\u9fff]')


def recover_mojibake(text_utf8: str) -> str:
    """utf8 -> gb18030 bytes -> utf8，还原被 GBK 误解码后再存为 UTF-8 的双重乱码。"""
    try:
        return text_utf8.encode('gb18030', errors='strict').decode('utf-8', errors='replace')
    except (UnicodeEncodeError, UnicodeDecodeError):
        return text_utf8


def diagnose(raw: bytes) -> tuple[str, str, int]:
    """返回 (诊断结论, 最佳解码文本, 汉字数)。"""
    as_utf8 = raw.decode('utf-8', errors='replace')
    as_gb = raw.decode('gb18030', errors='replace')

    utf8_cjk = len(CJK.findall(as_utf8))
    gb_cjk = len(CJK.findall(as_gb))

    # 双重 mojibake 的特征：UTF-8 解码得到大量高位替换字符，且原始字节其实是合法 GBK。
    if utf8_cjk < 50 and gb_cjk > 200:
        recovered = recover_mojibake(as_utf8)
        rec_cjk = len(CJK.findall(recovered))
        if rec_cjk > gb_cjk:
            return 'double-mojibake', recovered, rec_cjk
        return 'gb18030', as_gb, gb_cjk

    if utf8_cjk > 200:
        return 'utf8', as_utf8, utf8_cjk

    if gb_cjk > 200:
        return 'gb18030', as_gb, gb_cjk

    return 'unknown', as_gb, gb_cjk


def paren_balance(text: str) -> tuple[int, int, bool]:
    """统计圆括号配对（忽略注释与字符串内容）。"""
    depth = opens = closes = 0
    in_str = False
    i = 0
    while i < len(text):
        ch = text[i]
        if in_str:
            if ch == '\\':
                i += 2
                continue
            if ch == '"':
                in_str = False
        else:
            if ch == '"':
                in_str = True
            elif ch == ';':
                while i < len(text) and text[i] != '\n':
                    i += 1
                continue
            elif ch == '(':
                opens += 1
                depth += 1
            elif ch == ')':
                closes += 1
                depth -= 1
        i += 1
    return opens, closes, depth == 0


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2

    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) > 2 else src.replace('.lsp', '_fixed.lsp')

    raw = open(src, 'rb').read()
    verdict, text, cjk = diagnose(raw)
    text = text.replace('\ufffd', '')

    opens, closes, balanced = paren_balance(text)
    print(f'source     : {src} ({len(raw)} bytes)')
    print(f'diagnosis  : {verdict}   CJK readable = {cjk}')
    print(f'parens     : {opens} open / {closes} close -> {"BALANCED" if balanced else "UNBALANCED"}')

    with open(dst, 'wb') as fh:
        fh.write(text.encode('gb18030', errors='replace'))
    print(f'written    : {dst} (gb18030, AutoCAD-loadable)')

    if not balanced:
        print('WARNING: parentheses are not balanced; AutoCAD load will fail.')
        return 1
    if cjk < 50:
        print('WARNING: no readable Chinese found — check the source encoding.')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())

