FROM zondax/ledger-docker-bolos

ENV BOLOS_ENV=/opt/bolos
ENV BOLOS_SDK=$BOLOS_ENV/nanos-secure-sdk

RUN git clone https://github.com/LedgerHQ/nanos-secure-sdk.git $BOLOS_SDK

USER test
