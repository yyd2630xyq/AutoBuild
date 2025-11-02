# --------------------------------------------------------------------------------------------------
# @details
# This Makefile automates the build process, including
# pre-build, compiling source files, linking objects, and post-build.
# It supports incremental builds and ensures consistent and efficient compilation.
#
# $(MAKE) all
# │
# └──> all-build
#      │
#      ├──> $(MAKE) pre-build
#      │
#      ├──> $(MAKE) pre-make.args
#      │
#      ├──> $(MAKE) pre-make.scnt
#      │    │
#      │    └──> $(MAKE) $(TARGET)
#      │
#      └──> $(MAKE) post-build
#
# $(MAKE) inc-stats
# │
# ├──> $(MAKE) inc-stats.phony
# │
# └──> $(MAKE) inc-stats.sort
# --------------------------------------------------------------------------------------------------

define BANNER_ART
            ______                   _____________
           /|_||_\`.__          ____//__][__][___|
          (   _    _ _\        (o  _|  -|     _ o|
          =`-(_)--(_)-'         `-(_)--------(_)-'
endef

# ================================================================================================ #
#                                           common func                                            #
# ================================================================================================ #
# variables set in environment
# 0: local, 1: remote(local), 2: remote(remote)
REMOTE_MODE   ?= 0
FORCE_TTY     ?= 0
FD1           ?= 0
FD2           ?= 0
# variables common
TRUE          := T
FALSE         :=
EMPTY         :=
SPACE         := $(EMPTY) $(EMPTY)
TAB           := $(EMPTY)	$(EMPTY)
define NEWLINE
$(EMPTY)
$(EMPTY)
endef

CHARS_DIGIT   := 0 1 2 3 4 5 6 7 8 9
CHARS_ALL     := 0 1 2 3 4 5 6 7 8 9                                               \
                 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z               \
                 a b c d e f g h i j k l m n o p q r s t u v w x y z               \
                 ` ~ ! @ \# $$ % ^ & * ( ) - _ = + { } [ ] \ : ; ' " < > , . / ? |

repeat_100_int = $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 \
                 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 \
                 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 \
                 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1
gen_space_int  = $(if $1,$(foreach w,$1,)$(SPACE))
strlen_int_i   = $(if $1,$(call $0,$(wordlist 2,$(words $1),$1),$(subst $(firstword $1),x,$2)),$2)
strlen_int     = $(subst x,x ,$(call strlen_int_i,$2,$(subst $(TAB),x,$(subst $(SPACE),x,$1))))
subtract_int   = $(filter x,$(join $1,$2))
percent_int    = $(filter m,$(subst $2,m,$(call repeat_100_int,$1)))
half_int       = $(filter m,$(subst x x,m,$1))
align_num      = $(call gen_space_int,$(call subtract_int,$2,$(call strlen_int,$1,$(CHARS_DIGIT))))$1
rwildcard      = $(foreach d,$(wildcard $1),$(call $0,$d/*,$2)$(filter $2,$d))
unix2win_path  = $(if $1,$(call $0,$(wordlist 2,$(words $1),$1),$(patsubst /$(firstword $1)/%,$(firstword $1):/%,$2)),$2)
even_words     = $(if $1,$(word 2,$1) $(call $0,$(wordlist 3,$(words $1),$1)))
reverse        = $(if $1,$(call $0,$(wordlist 2,$(words $1),$1)) $(firstword $1))
uniq           = $(eval __uniq_tmp :=)$(strip $(foreach w,$1,$(if $(filter $w,$(__uniq_tmp)),,$(eval __uniq_tmp += $w)$w)))
append_args    = $(if $2,$(file >> $1,$2))
cmp_string     = $(if $(subst x$1,,x$2)$(subst x$2,,x$1),$(FALSE),$(TRUE))
encode_int     = $(if $1,$(if $(call cmp_string,$(words $(wordlist 1,$1,$2)),$1),$(wordlist 1,$1,$2),$(call $0,$1,$(if $2,$2 $2,x))))
print_var      = $(info $$($1):$2$($1))
write_var      = $(info $$($1):$2Output to $(BUILD_DIR)/_var_$1.txt)                       \
                     $(file > $(BUILD_DIR)/_var_$1.txt,$(subst $(SPACE),$(NEWLINE),$($1)))

# print banner
ifeq ($(REMOTE_MODE), 2)
    BANNER_BORDER := +---- --- ---- --- ---- --- ---- --- ---- --- ---- --- ----+
else
    BANNER_BORDER := +----------------------------------------------------------+
endif
BANNER_INT    := $(call encode_int,50)
MAKEGOALS_INT := $(call strlen_int,$(MAKECMDGOALS),$(CHARS_ALL))
BANN_SP_L_INT := $(call half_int,$(call subtract_int,$(BANNER_INT),$(MAKEGOALS_INT)))
BANN_SP_R_INT := $(call subtract_int,$(BANNER_INT),$(BANN_SP_L_INT) $(MAKEGOALS_INT))
$(info )
$(info $(BANNER_BORDER))
$(info | >>>$(call gen_space_int,$(BANN_SP_L_INT))$(MAKECMDGOALS)$(call gen_space_int,$(BANN_SP_R_INT))<<< |)
$(info $(BANNER_BORDER))

# ================================================================================================ #
#                                           user options                                           #
# ================================================================================================ #
# variables set in command line
SCRIPT_NAME     ?=
PWD_PATH        ?= $(shell busybox pwd)
BUILD_PATH      := build/
SRC             := ./
SRC_OUT         :=
SRC_ADD         :=
LD_FILE         :=
DST_PATH        :=
DST_JSON        :=
MCU             := s32k14x
TARGET          := default.elf

# format variables
PWD_DIR         := $(patsubst %/,%,$(subst \,/,$(PWD_PATH)))
BUILD_DIR       := $(if $(BUILD_PATH),$(patsubst %/,%,$(subst \,/,$(BUILD_PATH))),build)
SRC_TRIM        := $(patsubst %/,%,$(subst \,/,$(SRC)))
SRC_OUT_TRIM    := $(patsubst %/,%,$(subst \,/,$(SRC_OUT)))
SRC_ADD_TRIM    := $(patsubst %/,%,$(subst \,/,$(SRC_ADD)))
LD_FILE_TRIM    := $(patsubst %/,%,$(subst \,/,$(LD_FILE)))
DST_DIR         := $(strip $(patsubst %/,%,$(subst \,/,$(DST_PATH))))
# expansion variables
INC_STATS_PATH  := $(if $(DST_DIR),$(DST_DIR),$(BUILD_DIR))
INC_STATS_FILE  := _inc_stats_$(TARGET).txt
TARGET_BASENAME := $(basename $(TARGET))
TARGET_SUFFIX   := $(suffix $(TARGET))

# ================================================================================================ #
#                                            common var                                            #
# ================================================================================================ #
THIS_MAKEFILE      := $(subst //,/,$(subst \,/,$(lastword $(MAKEFILE_LIST))))
BUILD_TOOLS_DIR    := $(abspath $(dir $(THIS_MAKEFILE))..)
BINUTILS_GNU_DIR   := $(BUILD_TOOLS_DIR)/binutils/gcc-10.2-arm32-eabi
SHELL              := $(BUILD_TOOLS_DIR)/binutils/shell-env/usr/bin/sh.exe
DATE               := $(BUILD_TOOLS_DIR)/binutils/shell-env/usr/bin/busybox.exe date
ECHO               := $(BUILD_TOOLS_DIR)/binutils/shell-env/usr/bin/busybox.exe echo
MKDIR              := $(BUILD_TOOLS_DIR)/binutils/shell-env/usr/bin/busybox.exe mkdir
RM                 := $(BUILD_TOOLS_DIR)/binutils/shell-env/usr/bin/busybox.exe rm
START_TIME         := $(if $(filter all,$(MAKECMDGOALS)),$(shell $(DATE) '+%s'))
CURDIR_WIN         := $(call unix2win_path,c d e f g C D E F G,$(CURDIR))
MCU_LIST           := $(basename $(notdir $(wildcard $(BUILD_TOOLS_DIR)/automake/driver_args/*.mcudef)))
TARGET_SUFFIX_LIST := .a .elf
DEPS_SUFFIX_LIST   := $(TARGET_SUFFIX_LIST) .scnt
MCU_IMPORT_BP_LIST := pre-make.scnt clean remote-keygen remote-push remote-pull remote-clean remote-build-all remote-build-clean help
VAR_SEARCH_LIST    := pre-make.args inc-stats.phony test
VAR_IMPORT_LIST    := pre-make.scnt $(BUILD_DIR)/$(TARGET)
COLOR_ANSI         := $(file < $(BUILD_TOOLS_DIR)/automake/color_ansi.mk)
SCNT_BUILD_INT     := $(EMPTY)
SCNT_TOTAL_INT     := $(call encode_int,$(SCNT_TOTAL))
SLEN_TOTAL_INT     := $(call strlen_int,$(SCNT_TOTAL),$(CHARS_DIGIT))

ifeq ($(strip $(FORCE_TTY)), 1)
    COLOR_FD1      := $(COLOR_ANSI)
    COLOR_FD2      := $(COLOR_ANSI)
else
    COLOR_FD1      := $(if $(filter 1,$(FD1)),$(COLOR_ANSI))
    COLOR_FD2      := $(if $(filter 1,$(FD2)),$(COLOR_ANSI))
endif
COLOR_FD1_RESET    := $(word  2,$(COLOR_FD1))
COLOR_FD1_GREEN    := $(word  8,$(COLOR_FD1))
COLOR_FD1_YELLOW   := $(word 10,$(COLOR_FD1))
COLOR_FD2_RESET    := $(word  2,$(COLOR_FD2))
COLOR_FD2_YELLOW   := $(word 10,$(COLOR_FD2))

LOG_STDERR         := 2> >(tee -a '$(BUILD_DIR)/_logs_stderr.txt' | while IFS= read -r line;  \
                           do echo "$(COLOR_FD2_YELLOW)$${line}$(COLOR_FD2_RESET)" >&2; done)

# ================================================================================================ #
#                                          import mcudef                                           #
# ================================================================================================ #
ifeq (, $(filter $(MAKECMDGOALS), $(MCU_IMPORT_BP_LIST)))
    # check mcu & target suffix
    ifeq (, $(filter $(MCU), $(MCU_LIST)))
        $(error MCU: "$(MCU)" unrecognized! MCU list: $(MCU_LIST))
    endif
    ifeq (, $(filter $(TARGET_SUFFIX), $(TARGET_SUFFIX_LIST)))
        $(error TARGET_SUFFIX: "$(TARGET_SUFFIX)" unrecognized! Suffix list: $(TARGET_SUFFIX_LIST))
    endif

    include $(BUILD_TOOLS_DIR)/automake/driver_args/$(MCU).mcudef

    # tools info
    LINK_ORDER := $(LINK_ORDER_$(MCU))
    AR_BIN     := $(AR_BIN_$(MCU))
    CC_BIN     := $(CC_BIN_$(MCU))
    RE_BIN     := $(RE_BIN_$(MCU))
    SZ_BIN     := $(SZ_BIN_$(MCU))
    WN_BIN     := $(WN_BIN_$(MCU))
    # build args
    CC_ARGS    := $(CC_ARGS_$(MCU))
    AS_ARGS    := $(AS_ARGS_$(MCU))
    LD_ARGS    := $(LD_ARGS_$(MCU))
    LIBS       := $(LIBS_$(MCU))
endif

# ================================================================================================ #
#                                         autoscan source                                          #
# ================================================================================================ #
ifneq (, $(filter $(MAKECMDGOALS), $(VAR_SEARCH_LIST)))
    # scan source files
    $(info [Scanning source]: *.h *.s *.c *.a *.ld ...)
    ADD_SRCS :=                           $(call rwildcard, $(SRC_ADD_TRIM), %.h %.H %.s %.S %.c %.C %.a %.A %.ld)
    OUT_SRCS := $(filter-out $(ADD_SRCS), $(call rwildcard, $(SRC_OUT_TRIM), %.h %.H %.s %.S %.c %.C %.a %.A %.ld))
    ALL_SRCS := $(filter-out $(OUT_SRCS), $(call rwildcard, $(SRC_TRIM),     %.h %.H %.s %.S %.c %.C %.a %.A %.ld))
    H_SRCS   := $(filter %.h %.H, $(ALL_SRCS))
    S_SRCS   := $(filter %.s %.S, $(ALL_SRCS))
    C_SRCS   := $(filter %.c %.C, $(ALL_SRCS))
    A_SRCS   := $(filter %.a %.A, $(ALL_SRCS))
    LD_SRCS  := $(if $(LD_FILE_TRIM),$(LD_FILE_TRIM),$(filter %flash.ld, $(ALL_SRCS)))

    # H_SRCS -> I_PATH
    H_PATH_RAW := $(call uniq, $(dir $(H_SRCS)))
    H_STAT_RAW := $(call even_words,$(file < $(if $(wildcard $(DST_DIR)/$(INC_STATS_FILE)),$(DST_DIR),$(BUILD_DIR))/$(INC_STATS_FILE)))
    H_STAT_ADD := $(filter $(H_PATH_RAW), $(H_STAT_RAW))
    H_STAT_OUT := $(filter-out $(H_PATH_RAW), $(H_STAT_RAW))
    H_STAT_MIS := $(filter-out $(H_STAT_RAW), $(H_PATH_RAW))
    H_PATH     := $(call uniq, $(H_STAT_ADD) $(H_PATH_RAW))
    I_PATH     := $(addprefix -I$(CURDIR_WIN)/, $(H_PATH))
    $(info [Inc-stats merge]: $(words $(H_STAT_ADD)) / $(words $(H_STAT_RAW)) / $(words $(H_PATH_RAW)) (stats_add / stats_raw / path_raw))

    # S_SRCS, C_SRCS -> OBJECTS
    ifeq ($(LINK_ORDER), GNU)
        OBJECTS := $(call reverse, $(sort $(dir $(S_SRCS) $(C_SRCS))))
        OBJECTS := $(foreach d, $(OBJECTS), $(sort $(wildcard $d*.[sScC])))
        OBJECTS := $(filter $(S_SRCS) $(C_SRCS), $(OBJECTS))
        OBJECTS := $(patsubst %.s,%.o,$(patsubst %.S,%.o,$(OBJECTS)))
        OBJECTS := $(patsubst %.c,%.o,$(patsubst %.C,%.o,$(OBJECTS)))
    else
        OBJECTS := $(patsubst %.s,%.o,$(patsubst %.S,%.o,$(S_SRCS))) $(patsubst %.c,%.o,$(patsubst %.C,%.o,$(C_SRCS)))
        OBJECTS := $(patsubst %0o,%.o,$(sort $(patsubst %.o,%0o,$(OBJECTS))))
    endif
    OBJECTS := $(addprefix $(BUILD_DIR)/, $(OBJECTS))

    # export var
    ifeq ($(MAKECMDGOALS), pre-make.args)
        $(file > $(BUILD_DIR)/_export_vars.mk, $(foreach var,A_SRCS LD_SRCS I_PATH OBJECTS,$(var) := $($(var))$(NEWLINE)))
        $(info [Export var-scan]: ---> A_SRCS LD_SRCS I_PATH OBJECTS)
    endif

    $(info )
endif

# import var
ifneq (, $(filter $(MAKECMDGOALS), $(VAR_IMPORT_LIST)))
    $(info [Import var-scan]: <--- A_SRCS LD_SRCS I_PATH OBJECTS)
    include $(BUILD_DIR)/_export_vars.mk
endif

# ================================================================================================ #
#                                           dependencies                                           #
# ================================================================================================ #
ifneq (, $(filter $(suffix $(MAKECMDGOALS)), $(DEPS_SUFFIX_LIST)))
    $(info [Import dep-file]: *.d)
    -include $(patsubst %.o,%.d,$(OBJECTS))
endif

# ================================================================================================ #
#                                      build the application                                       #
# ================================================================================================ #
all: all-build
	$(info )
	@output_text='[Build Finished]:'; color_set='$(COLOR_FD1_GREEN)';           \
	if [ -n '$(strip $(WN_BIN))' ]; then                                        \
		read errors warnings < <($(WN_BIN) $(BUILD_DIR)/_logs_stderr.txt);      \
		[ $$(( errors + warnings )) -ne 0 ] && color_set='$(COLOR_FD1_YELLOW)'; \
		output_text="$$output_text $$errors errors, $$warnings warnings.";      \
	fi;                                                                         \
	read dTime nTime < <(date '+%s %H:%M:%S');                                  \
	mTime=$$(( (dTime - $(START_TIME)) / 60 ));                                 \
	sTime=$$(( (dTime - $(START_TIME)) % 60 ));                                 \
	if [ "$$mTime" -ne 0 ]; then                                                \
		output_text="$$output_text $$nTime (took $${mTime}m:$${sTime}s)";       \
	else                                                                        \
		output_text="$$output_text $$nTime (took $${sTime}s)";                  \
	fi;                                                                         \
	echo "$${color_set}$${output_text}$(COLOR_FD1_RESET)"

all-build: | $(BUILD_DIR)
ifeq ($(REMOTE_MODE), 0)
	$(info $(BANNER_ART))
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory pre-build
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory pre-make.args
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory pre-make.scnt
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory post-build
else ifeq ($(REMOTE_MODE), 1)
	$(info $(BANNER_ART))
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory pre-build
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory remote-push
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory remote-build-all
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory remote-pull
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory post-build
else ifeq ($(REMOTE_MODE), 2)
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory pre-make.args
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory pre-make.scnt
endif

# ------------------------------------------------------------------------------
# pre-make.args
# checks if _args_%.txt is missing or outdated and generates it for ar, ld, cc, as
# keep _new_args_%.txt for debugging using .SECONDARY (prevent automatic deletion)
# .SECONDARY: $(patsubst %,$(BUILD_DIR)/_new_args_%.txt,ar ld cc as)
# ------------------------------------------------------------------------------
pre-make.args: $(patsubst %,_new_args_%.txt.phony,ar ld cc as)
	@:

_new_args_%.txt.phony: $(BUILD_DIR)/_new_args_%.txt
	$(if $(wildcard $(BUILD_DIR)/_args_$*.txt),                                        \
		$(if $(call cmp_string,$(file < $(BUILD_DIR)/_args_$*.txt),$(file < $<)),      \
			$(info [Building option]: $(BUILD_DIR)/_args_$*.txt (already up to date)), \
			$(info [Building option]: $(BUILD_DIR)/_args_$*.txt (is out of date))      \
				$(file > $(BUILD_DIR)/_args_$*.txt,$(file < $<))                       \
		),                                                                             \
		$(info [Building option]: $(BUILD_DIR)/_args_$*.txt (is not present))          \
			$(file > $(BUILD_DIR)/_args_$*.txt,$(file < $<))                           \
	)

$(BUILD_DIR)/%args_ar.txt: | $(BUILD_DIR)
	$(file > $@)
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(OBJECTS)))

$(BUILD_DIR)/%args_ld.txt: | $(BUILD_DIR)
	$(file > $@)
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(addprefix -T , $(LD_SRCS))))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(LD_ARGS)))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(strip $(EXTRA_LD_ARGS))))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(OBJECTS)))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(A_SRCS)))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(LIBS)))

$(BUILD_DIR)/%args_cc.txt: | $(BUILD_DIR)
	$(file > $@)
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(CC_ARGS)))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(strip $(EXTRA_CC_ARGS))))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(I_PATH)))

$(BUILD_DIR)/%args_as.txt: | $(BUILD_DIR)
	$(file > $@)
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(AS_ARGS)))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(strip $(EXTRA_AS_ARGS))))
	$(call append_args,$@,$(subst $(SPACE),$(NEWLINE),$(I_PATH)))

# ------------------------------------------------------------------------------
# pre-make.scnt
# dry run for $(TARGET) to count total objs that need updating
# ------------------------------------------------------------------------------
pre-make.scnt: $(BUILD_DIR)/$(TARGET)
	$(info [Pre-make scount]: ( $(words $(SCNT_TOTAL_INT)) ) files need to be compiled)
	$(file > $(BUILD_DIR)/_logs_stderr.txt)
ifneq (, $(strip $(OBJECTS)))
	@$(MKDIR) -p $(sort $(dir $(OBJECTS)))
endif
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory $(BUILD_DIR)/$(TARGET) SCNT_TOTAL=$(words $(SCNT_TOTAL_INT))
	@$(RM) -f '$(BUILD_DIR)/_export_vars.mk'

pre-build:
ifneq (, $(strip $(user_prebuild))$(strip $(arg_prebuild)))
	$(info PreBuild.bat $(user_prebuild) $(arg_prebuild))
	@$(BUILD_TOOLS_DIR)/PreBuild.bat $(user_prebuild) $(arg_prebuild)
endif

post-build:
ifeq ($(TARGET_SUFFIX), .a)
    ifneq (, $(DST_DIR))
		$(info PostBuild_Lib.bat CrossToolsPath CrossPrefix $(TARGET_BASENAME) $(BUILD_DIR) $(firstword $(SRC_TRIM)) $(DST_DIR)/$(MCU))
		@$(BUILD_TOOLS_DIR)/PostBuild_Lib.bat CrossToolsPath CrossPrefix $(TARGET_BASENAME) $(BUILD_DIR) $(firstword $(SRC_TRIM)) $(DST_DIR)/$(MCU)
    endif
else ifeq ($(TARGET_SUFFIX), .elf)
    ifneq (, $(and $(DST_DIR), $(strip $(DST_JSON))))
		$(info PostBuild.bat $(DST_DIR) $(DST_JSON) $(BUILD_DIR) $(TARGET_BASENAME) CrossToolsPath CrossPrefix $(user_postbuild) $(arg_postbuild))
		@$(BUILD_TOOLS_DIR)/PostBuild.bat $(DST_DIR) $(DST_JSON) $(BUILD_DIR) $(TARGET_BASENAME) CrossToolsPath CrossPrefix $(user_postbuild) $(arg_postbuild)
		@$(ECHO)
    endif
		@$(ECHO) '[RE]: $(BUILD_DIR)/$(TARGET_BASENAME).elf'
		@$(RE_BIN) -S $(BUILD_DIR)/$(TARGET_BASENAME).elf
		@$(ECHO)
		@$(ECHO) '[SZ]: $(BUILD_DIR)/$(TARGET_BASENAME).elf'
		@$(SZ_BIN) $(BUILD_DIR)/$(TARGET_BASENAME).elf
endif

$(BUILD_DIR)/$(TARGET_BASENAME).a: $(BUILD_DIR)/_args_ar.txt $(OBJECTS)
ifneq ($(MAKECMDGOALS), pre-make.scnt)
	$(info )
	$(info [AR]: $@)
	@$(AR_BIN) -rcDv $@ @$< $(LOG_STDERR)
endif

$(BUILD_DIR)/$(TARGET_BASENAME).elf: $(BUILD_DIR)/_args_ld.txt $(OBJECTS) $(LD_SRCS) $(A_SRCS)
ifneq ($(MAKECMDGOALS), pre-make.scnt)
	$(info )
	$(info [LD]: $@)
	@$(CC_BIN) -o $@ @$< $(LOG_STDERR)
endif

# ------------------------------------------------------------------------------
# OBJECT_RULE
# generic pattern rule to build object files
# param(src-ext)          $1 source file extension    (c,  C,  s,  S)
# param(args-file-suffix) $2 suffix of argument file  (cc, cc, as, as)
# param(print-label)      $3 label for logging output (CC, CC, AS, AS)
# ------------------------------------------------------------------------------
define OBJECT_RULE
    $(BUILD_DIR)/%.o: %.$1 $(BUILD_DIR)/_args_$2.txt
    ifeq ($(MAKECMDGOALS), pre-make.scnt)
		$$(eval SCNT_TOTAL_INT += x)
    else
		$$(eval SCNT_BUILD_INT += x)
		$$(info [$$(call align_num,$$(words $$(call percent_int,$$(SCNT_BUILD_INT),$$(SCNT_TOTAL_INT))),x x x)%             \
				 $$(call align_num,$$(words $$(call subtract_int,$$(SCNT_TOTAL_INT),$$(SCNT_BUILD_INT))),$(SLEN_TOTAL_INT)) \
				 $3]: $$<)
		@$(CC_BIN) @$(BUILD_DIR)/_args_$2.txt -MD -o $$@ $(CURDIR_WIN)/$$< $$(LOG_STDERR)
    endif
endef

$(foreach suffix,c s C S,$(eval $(call OBJECT_RULE,$(suffix),$(if $(filter c C,$(suffix)),cc,as),$(if $(filter c C,$(suffix)),CC,AS))))

%.h: ;

$(BUILD_DIR):
	@$(MKDIR) -p $@

# ================================================================================================ #
#                                        include statistics                                        #
# ================================================================================================ #
inc-stats: | $(BUILD_DIR)
	$(info [Inc-stats]: removing previous $(INC_STATS_FILE) ...)
	$(info rm -f '$(DST_DIR)/$(INC_STATS_FILE)')
	$(info rm -f '$(BUILD_DIR)/$(INC_STATS_FILE)')
	@$(RM) -f '$(DST_DIR)/$(INC_STATS_FILE)'
	@$(RM) -f '$(BUILD_DIR)/$(INC_STATS_FILE)'
	@$(MKDIR) -p $(INC_STATS_PATH)
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory inc-stats.phony
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory inc-stats.sort

inc-stats.phony: $(patsubst %.o,%.d.txt,$(OBJECTS))
	@:
	$(info [merging]: *.d.txt ...)
	$(eval INC_STATS_MERGE := $$(abspath $$(subst \:,:,$$(foreach d,$$^,$$(file < $$d)))))
	$(eval INC_STATS_MERGE := $$(patsubst $(CURDIR_WIN)/%,%/,$$(filter $(CURDIR_WIN)/%,$$(INC_STATS_MERGE))))
	$(file > $(INC_STATS_PATH)/$(INC_STATS_FILE).tmp,$(subst $(SPACE),$(NEWLINE),$(INC_STATS_MERGE)))

inc-stats.sort:
	$(info [Inc-stats]: sorting include path ...)
	@sort $(INC_STATS_PATH)/$(INC_STATS_FILE).tmp | uniq -c | sort -nr > $(INC_STATS_PATH)/$(INC_STATS_FILE)
	@$(RM) '$(INC_STATS_PATH)/$(INC_STATS_FILE).tmp'
	@$(ECHO) '[Inc-stats]: finished building $(INC_STATS_PATH)/$(INC_STATS_FILE)'

%.d.txt: %.d
	$(info [parsing]: $<)
	@$(BUILD_TOOLS_DIR)/automake/scripts/collect_deps.sh $< $@

# ================================================================================================ #
#                                             clean up                                             #
# ================================================================================================ #
clean:
ifeq ($(REMOTE_MODE), 0)
	$(info rm -rf '$(BUILD_DIR)/')
	@$(RM) -rf '$(BUILD_DIR)/'
else ifeq ($(REMOTE_MODE), 1)
	$(info rm -rf '$(BUILD_DIR)/')
	@$(RM) -rf '$(BUILD_DIR)/'
	@$(MAKE) -f $(THIS_MAKEFILE) --no-print-directory remote-build-clean
else ifeq ($(REMOTE_MODE), 2)
	$(info rm -rf '$(BUILD_DIR)/')
	@$(RM) -rf '$(BUILD_DIR)/'
endif

# ================================================================================================ #
#                       remote keygen/push/pull/clean/build-all/build-clean                        #
# ================================================================================================ #
remote-keygen remote-push remote-pull remote-clean remote-build-all remote-build-clean:
ifneq ($(REMOTE_MODE), 2)
	@$(BUILD_TOOLS_DIR)/automake/scripts/remote_build.sh $(PWD_DIR) $(BUILD_DIR) $(SCRIPT_NAME) \
		$(patsubst all,all-build,$(patsubst remote-build-%,%,$@))
endif

# ================================================================================================ #
#                                               help                                               #
# ================================================================================================ #
help:
	@:
	$(info $(EMPTY)Usage: make [BUILD_PATH=<build_path>] [SRC=<src_dir>] [SRC_OUT=<src_out_dir>]           \)
	$(info $(EMPTY)            [SRC_ADD=<src_add_dir>] [LD_FILE=<ld_file_path>] [DST_PATH=<dst_path>]      \)
	$(info $(EMPTY)            [DST_JSON=<dst_json_file>] [MCU=<mcu_type>] [EXTRA_CC_ARGS=<extra_cc_args>] \)
	$(info $(EMPTY)            [EXTRA_AS_ARGS=<extra_as_args>] [EXTRA_LD_ARGS=<extra_ld_args>]             \)
	$(info $(EMPTY)            [TARGET=<target_name>] [make_target] [-j[N]])
	$(info )
	$(info build_path:    default: build/            (optional, build workspace path))
	$(info src_dir:       default: ./)
	$(info $(EMPTY)               valid: "dir...")
	$(info src_out_dir:   Source file exclude path   (optional))
	$(info src_add_dir:   Source file add path       (optional, add source excluded by src_out_dir again))
	$(info ld_file_path:  Linker file path           (optional, auto search *flash.ld if not provided))
	$(info dst_path:      Release path for PostBuild (optional))
	$(info dst_json_file: Json file for PostBuild    (optional))
	$(info mcu_type:      default: s32k14x)
	$(info $(EMPTY)               valid: $(wordlist 1,4,$(MCU_LIST)) \)
	$(info $(EMPTY)                      $(wordlist 5,$(words $(MCU_LIST)),$(MCU_LIST)))
	$(info extra_cc_args: Extra cc args              (optional))
	$(info extra_as_args: Extra as args              (optional))
	$(info extra_ld_args: Extra ld args              (optional))
	$(info target_name:   default: default.elf)
	$(info $(EMPTY)               valid: target_name[$(TARGET_SUFFIX_LIST)])
	$(info make_target:   default: all)
	$(info $(EMPTY)               valid: all[--remote] clean[--remote] pre-build post-build inc-stats help test \)
	$(info $(EMPTY)                      remote-keygen remote-push remote-pull remote-clean                     \)
	$(info $(EMPTY)                      remote-build-all remote-build-clean)

# ================================================================================================ #
#                                               test                                               #
# ================================================================================================ #
test: pre-make.args
	$(info )
	$(call print_var,BUILD_DIR,       )
	$(call print_var,THIS_MAKEFILE,   )
	$(call print_var,CURDIR_WIN,      )
	$(call print_var,BUILD_TOOLS_DIR, )
	$(call print_var,TARGET,          )
	$(call write_var,ADD_SRCS,        )
	$(call write_var,OUT_SRCS,        )
	$(call write_var,ALL_SRCS,        )
	$(call write_var,H_SRCS,          )
	$(call write_var,S_SRCS,          )
	$(call write_var,C_SRCS,          )
	$(call write_var,A_SRCS,          )
	$(call write_var,LD_SRCS,         )
	$(call write_var,H_STAT_RAW,      )
	$(call write_var,H_STAT_ADD,      )
	$(call write_var,H_STAT_OUT,      )
	$(call write_var,H_STAT_MIS,      )
	$(call write_var,H_PATH_RAW,      )
	$(call write_var,H_PATH,          )
	$(call write_var,I_PATH,          )
	$(call write_var,OBJECTS,         )
	@$(ECHO) '[Color test]:       FORCE_TTY:$(FORCE_TTY) $(COLOR_FD1_GREEN)FD1:$(FD1)$(COLOR_FD1_RESET) $(COLOR_FD2_YELLOW)FD2:$(FD2)$(COLOR_FD2_RESET)'

# ================================================================================================ #
#                                          phony targets                                           #
# ================================================================================================ #
.PHONY: all all-build pre-build post-build pre-make.args pre-make.scnt                         \
		inc-stats inc-stats.phony inc-stats.sort clean                                         \
		remote-keygen remote-push remote-pull remote-clean remote-build-all remote-build-clean \
		help test
