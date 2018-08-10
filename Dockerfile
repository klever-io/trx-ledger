FROM zondax/ledger-docker-bolos

ENV BOLOS_ENV=/opt/bolos
# ENV BOLOS_SDK=$BOLOS_ENV/nanos-secure-sdk
ENV BOLOS_SDK=$BOLOS_ENV/blue-secure-sdk

# RUN git clone https://github.com/LedgerHQ/nanos-secure-sdk.git $BOLOS_SDK
RUN git clone https://github.com/ledgerhq/blue-secure-sdk $BOLOS_SDK
RUN apt-get update && apt-get install -y \
	python3-pip


USER test
