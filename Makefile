# Default mode is debug
MODE=debug
# Uncomment this if you have mold installed
USE_MOLD=1

ifeq ($(MODE),debug)
	MODE_CFLAGS = -g
	ifeq ($(USE_MOLD),1)
		LDFLAGS += -fuse-ld=mold -L/usr/local/lib
	endif
else
	MODE_CFLAGS = -march=native -O3 -flto=auto
	ifeq ($(MODE),generate)
		MODE_CFLAGS += -fprofile-generate
		LDFLAGS += -fuse-ld=mold -L/usr/local/lib
		LDFLAGS += -fprofile-generate
	else ifeq ($(MODE),use)
		MODE_CFLAGS += -fprofile-use
	else ifneq ($(MODE),opt)
		MODE_CFLAGS = $(error Unknown compilation mode '$(MODE)')
	endif
endif

LDLIBS := -lasound -lm -lfftw3 -lfftw3f -pthread -lncurses -lsqlite3 -lnsl -lrt \
					$(shell pkg-config --libs gtk+-3.0)
CFLAGS := $(shell pkg-config --cflags gtk+-3.0) $(MODE_CFLAGS) -Ithird_party/WiringPi/wiringPi

FT8 = ft8_lib
WIRINGPI = third_party/WiringPi/wiringPi

LIBFT8_A = $(FT8)/libft8.a
LIBWIRINGPI_A = $(WIRINGPI)/libwiringPi.a

SRCS = vfo.c si570.c sbitx_sound.c fft_filter.c sbitx_gtk.c sbitx_utils.c \
			 i2cbb.c si5351v2.c ini.c hamlib.c queue.c modems.c logbook.c \
			 modem_cw.c settings_ui.c oled.c \
			 telnet.c macros.c modem_ft8.c remote.c mongoose.c webserver.c sbitx.c

OBJS = $(SRCS:.c=.o)

all: sbitx

clean:
	rm -f sbitx $(OBJS)

sbitx: $(OBJS) $(LIBFT8_A) $(LIBWIRINGPI_A)

$(LIBFT8_A):
	$(MAKE) -C $(FT8) libft8.a

$(LIBWIRINGPI_A):
	$(MAKE) -C $(WIRINGPI) libwiringPi.a

.PHONY: .FORCE
