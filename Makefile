ARDUINO_DEV_NODE:=$(shell arduino-cli board list | grep -m1 mega | cut -d' ' -f1)
ARDUINO_LIB_PATH:=$(shell arduino-cli config dump | grep -m1 "user:" | cut -d: -f2)/libraries
ARDUINO_LIBS_SRC:=$(realpath deps/freenove/ArduinoLibraries)
ARDUINO_LIBS_SRC_ZIPS:=$(wildcard $(ARDUINO_LIBS_SRC)/*.zip)
ARDUINO_STD_LIBS := $(ARDUINO_LIB_PATH)/Servo
ARDUINO_LIBS := $(basename $(subst $(ARDUINO_LIBS_SRC),$(ARDUINO_LIB_PATH),$(ARDUINO_LIBS_SRC_ZIPS)))
ARDUINO_LIBS += $(ARDUINO_STD_LIBS)

ifeq ($(ARDUINO_LIB_PATH),)
  $(error Unable to find arduino-cli library path!)
endif

#ifeq ($(ARDUINO_DEV_NODE),)
#  $(error Unable to find device!)
#endif

$(info Arduino libraries are installed in $(ARDUINO_LIB_PATH))

.PHONY: all clean build

all: upload

define arduino_zip_lib_install_rule
$(basename $(subst $(ARDUINO_LIBS_SRC),$(ARDUINO_LIB_PATH),$(1))): $(1)
	unzip $$^ -d $(ARDUINO_LIB_PATH)
	touch $$@
endef

$(foreach LIB,$(ARDUINO_LIBS_SRC_ZIPS),$(eval $(call arduino_zip_lib_install_rule,$(LIB))))

define arduino_std_lib_install_rule
$(1):
	arduino-cli lib install $(notdir $(1))
endef

$(foreach LIB,$(ARDUINO_STD_LIBS),$(eval $(call arduino_std_lib_install_rule,$(LIB))))

hexapod/build/arduino.avr.mega: hexapod/hexapod.ino $(ARDUINO_LIBS)
	arduino-cli core install arduino:avr
	arduino-cli compile --fqbn arduino:avr:mega $<

build: hexapod/build/arduino.avr.mega

upload: hexapod/build/arduino.avr.mega
	arduino-cli upload --fqbn arduino:avr:mega --port $(ARDUINO_DEV_NODE) hexapod

clean:
	rm -rf hexapod/build

