# Readme

HDU 编译原理实验 JavaScript 实现（基于 jison）

对 S 语言进行词法分析、语法分析和部分语法的中间代码生成。

S 语言定义请参照实验指导书。

## 说明

文件

* slex.jison - 词法分析 jison 定义
* slex.js - jison 生成的词法分析程序
* s.jison - 语法分析 jison 定义 最终会输出 AST
* s.js - jison 生成的语法分析程序
* output.json - 语法分析程序输出的 AST
* test0.txt - 语法分析测试用例
* sgen.js - 中间代码生成 输出三元组 不支持分支、循环 基于上一步的 output.json
* test1.txt - 中间代码生成测试用例