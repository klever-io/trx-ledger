FROM zondax/ledger-docker-bolos

ENV BOLOS_ENV=/opt/bolos
ENV BOLOS_SDK=$BOLOS_ENV/nanos-secure-sdk
#ENV BOLOS_SDK=$BOLOS_ENV/blue-secure-sdk

RUN git clone https://github.com/LedgerHQ/nanos-secure-sdk.git $BOLOS_ENV/nanos-secure-sdk
RUN git clone https://github.com/ledgerhq/blue-secure-sdk $BOLOS_ENV/blue-secure-sdk
RUN apt-get update && apt-get install -y \
	python3-pip

RUN cd /tmp \
&& wget http://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2 \
&& tar -jxf make-4.2.1.tar.bz2 \
&& cd make-4.2.1 \
&& ./configure --prefix=/usr \
&& make \
make install


USER test
