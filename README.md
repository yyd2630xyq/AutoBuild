# AutoBuild
Automates the build process, including pre-build, compiling source files, linking objects, and post-build.<br>
It supports incremental builds and ensures consistent and efficient compilation.

# QSG
Just Run `build_elf.bat` or `build_lib.bat`<br>
[Autosar Makefile](https://www.bilibili.com/video/BV1PtMRzwETe/?share_source=copy_web&vd_source=99511122be35db3b6b30e3a2360c02bf)<br>
[如何实现自动化Makefile](https://www.bilibili.com/video/BV1YqbdziEWL/?share_source=copy_web&vd_source=99511122be35db3b6b30e3a2360c02bf)<br>
[Makefile 增量构建之 头文件依赖链](https://www.bilibili.com/video/BV1UuhPzDE7H/?share_source=copy_web&vd_source=99511122be35db3b6b30e3a2360c02bf)<br>
[提升100%编译性能 头文件搜索路径优化](https://www.bilibili.com/video/BV1QwbWzgE1R/?share_source=copy_web&vd_source=99511122be35db3b6b30e3a2360c02bf)

```
$(MAKE) all
│
└──> all-build
	│
	├──> $(MAKE) pre-build
	│
	├──> $(MAKE) pre-make.args
	│
	├──> $(MAKE) pre-make.scnt
	│    │
	│    └──> $(MAKE) $(TARGET)
	│
	└──> $(MAKE) post-build

$(MAKE) inc-stats
│
├──> $(MAKE) inc-stats.phony
│
└──> $(MAKE) inc-stats.sort
```
