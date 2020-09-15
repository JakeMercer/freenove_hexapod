DEV := $(shell arduino-cli board list | grep -m1 mega | cut -d' ' -f1)

.PHONY: all clean build

all: upload

hexapod/build/arduino.avr.mega: hexapod/hexapod.ino
	arduino-cli core install arduino:avr
	arduino-cli compile --fqbn arduino:avr:mega $^

build: hexapod/build/arduino.avr.mega

upload: hexapod/build/arduino.avr.mega
	arduino-cli upload --fqbn arduino:avr:mega --port $(DEV) hexapod

clean:
	rm -rf hexapod/build
