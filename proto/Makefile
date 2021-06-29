include ../nanopb/extra/nanopb.mk

DEFINES   += PB_NO_ERRMSG=1

TARGETS = core/Tron.pb.c core/Tron.pb.h \
	core/Contract.pb.c core/Contract.pb.h \
	misc/TronApp.pb.c misc/TronApp.pb.h \
	google/protobuf/any.pb.c google/protobuf/any.pb.h

default: ${TARGETS}

clean:
	rm -f ${TARGETS}