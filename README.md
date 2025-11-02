# AutoBuild
Automates the build process, including pre-build, compiling source files, linking objects, and post-build.

It supports incremental builds and ensures consistent and efficient compilation.

# QSG
Just Run `build_elf.bat` or `build_lib.bat`

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