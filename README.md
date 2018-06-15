


Test cases are based on the following seed:

```
abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about
```

Select 12 words, enter 11 times `abandon` and one time `about`.

> This is the seed phrase we are going to use everywhere. Obviously don't use it to store your funds (unless testnet).\
> First Private key from this seed is b5a4cea271ff424d7c31dc12a3e43e401df7a40d7412a15750f3f0b6b5449a28 \
> Public key:  04ff21f8e64d3a3c0198edfbb7afdc79be959432e92e2f8a1984bb436a414b8edcec0345aad0c1bf7da04fd036dd7f9f617e30669224283d950fab9dd84831dc83\
>  Address: 41c8599111f29c1e1e061265b4af93ea1f274ad78a\
> Address base 58: TUEZSdKsoDHQMeZwihtdoBiN46zxhGWYdH

# Installing Tron app for Ledger
Clone this repository:
```bash
git clone https://github.com/fbsobreira/trx-ledger.git
cd trx-ledger
```


# Docker toolchain image
In order to make compiling as eas as possible you can make use of a docker image containing all the neccessary compilers and the [nanos-secure-sdk](https://github.com/LedgerHQ/nanos-secure-sdk)

Inside the repository directory you'll find a Dockerfile for building a toolchain image.

Building the image:
```bash
docker build -t ledger-chain:latest .
```


#Compiling from source

The easiest way to compile from source is by building the Dockerfile.
Make sure you have [Docker](https://www.docker.com/community-edition) installed.

 
Using the Docker image:
```bash
docker run --rm -v "$(pwd)":/trx-ledger -w /trx-ledger ledger-chain make
```

Using your own toolchain:
```bash
docker run --rm -v "$(pwd)":/trx-ledger -w /trx-ledger ledger-chain make
```

# Load app onto Ledger Nano S

Make sure you have virtualenv available locally.
```bash
[sudo] pip install -U setuptools
[sudo] pip install virtualenv
```

Inside the repository directory create a new virtualenv for Python:
```bash
virtualenv -p python3 ledger
source ledger/bin/activate
pip install ledgerblue
```

Then run:
```bash
python -m ledgerblue.loadApp \
--targetId 0x31100003 \
--fileName bin/app.hex \
--icon `docker run --rm -v "$(pwd)":/trx_ledger -w /trx_ledger ledger-chain python /opt/bolos/nanos-secure-sdk/icon.py icon.gif hexbitmaponly` \
--curve secp256k1 \
--path "44'/195'/0'" \
--apdu \
--appName "Tron" \
--delete \
--tlv
```


Using your own toolchain:
```bash
docker run --rm -v "$(pwd)":/trx-ledger -w /trx-ledger ledger-chain make load
```


# Links
========

### [Tronscan Integration](https://github.com/tronscan/tronscan-frontend/tree/ledger)
### [Video Demo](https://www.youtube.com/watch?v=RYUiiGw-hHw&feature=youtu.be)
