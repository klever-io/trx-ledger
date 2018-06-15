FROM zondax/ledger-docker-bolos

ENV BOLOS_SDK=/opt/bolos/nanos-secure-sdk
RUN git clone https://github.com/LedgerHQ/nanos-secure-sdk.git $BOLOS_SDK

USER test
