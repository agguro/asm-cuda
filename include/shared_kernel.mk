# ==============================================================================
# LOW-LEVEL FRAMEWORK: SHARED KERNEL TEMPLATE (Autonomous PTX Target)
# ==============================================================================

# 1. TOOLCHAIN DETECTION & VALIDATION (Evaluated instantly during parsing phase)
PTXAS    := $(shell which ptxas 2>/dev/null)
NVDISASM := $(shell which nvdisasm 2>/dev/null)

ifeq ($(PTXAS),)
    $(error CRITICAL: 'ptxas' not found in $$PATH. Please install nvidia-cuda-toolkit!)
endif

ifeq ($(NVDISASM),)
    $(error CRITICAL: 'nvdisasm' not found in $$PATH. Please install nvidia-cuda-toolkit!)
endif

# 2. VARIABLES: Local context identification based on calling directory
CURRENT_DIR   := $(CURDIR)
NAME          := $(notdir $(CURRENT_DIR))

ARCHITECTURE  := sm_61
MODE          ?= debug

# 3. LOCAL SYSTEM PATHS (Build output isolated directly inside the kernel directory)
BUILD_DIR     := $(CURRENT_DIR)/build/$(MODE)

# 4. FILENAMES & TARGETS
SRC_PTX       := $(NAME).ptx
CUBIN         := $(BUILD_DIR)/$(NAME).cubin
SASS          := $(BUILD_DIR)/$(NAME).sass

# 5. TOOLCHAIN FLAGS
PTXASFLAGS    := -v -arch=$(ARCHITECTURE)
NVFLAGS       :=

# 6. MODE CONFIGURATION
ifeq ($(origin MODE), undefined)
    MODE := debug
endif

ifeq ($(MODE),release)
        PTXASFLAGS += -O3
        MSG        := "Kernel Build Mode: RELEASE"
        PIPELINE_SASS :=
else
        PTXASFLAGS += -lineinfo
        NVFLAGS    += -g
        MSG        := "Kernel Build Mode: DEBUG"
        PIPELINE_SASS := $(SASS)
endif

all:
	@$(MAKE) MODE=$(MODE) build_pipeline

debug:
	@$(MAKE) MODE=debug build_pipeline

release:
	@$(MAKE) MODE=release build_pipeline

build_pipeline: info directories $(CUBIN) $(PIPELINE_SASS)

# 7. COMPILATION RULES
info:
	@echo "=============================================================================="
	@echo $(MSG)
	@echo "Kernel:       $(NAME)"
	@echo "Architecture: $(ARCHITECTURE)"
	@echo "Source:       $(SRC_PTX) -> $(CUBIN)"
	@if [ "$(MODE)" = "debug" ]; then echo "SASS Dump:    $(SASS)"; fi
	@echo "=============================================================================="

directories:
	@mkdir -p $(BUILD_DIR)

$(CUBIN): $(SRC_PTX)
	@if [ ! -f $(SRC_PTX) ]; then echo "ERROR: $(SRC_PTX) not found in $(CURRENT_DIR)"; exit 1; fi
	$(PTXAS) $(PTXASFLAGS) $(SRC_PTX) -o $(CUBIN)
	@echo "--> GPU Kernel assembled successfully via ptxas to $(CUBIN)"

$(SASS): $(CUBIN)
	$(NVDISASM) $(NVFLAGS) $(CUBIN) > $(SASS)
	@echo "--> SASS source disassembled successfully to $(SASS)"
	@echo "--> Build completed successfully!"

# 8. CLEANUP
.PHONY: all debug release build_pipeline info directories clean

clean:
	@echo "Cleaning up local build artifacts for $(NAME)..."
	rm -rf $(CURRENT_DIR)/build
