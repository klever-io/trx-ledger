
# Test Case

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


# Compiling from source

## Docker toolchain image
In order to make compiling as eas as possible you can make use of a docker image containing all the necessary compilers and the [nanos-secure-sdk](https://github.com/LedgerHQ/nanos-secure-sdk).

Inside the repository directory you'll find a Dockerfile for building a toolchain image.

### Step 1 - Build the image:
```bash
docker build -t ledger-chain:latest .
```
The `.` at the end is important!

 
### Step 2 - Use Docker image
```bash
docker run --rm -v "$(pwd)":/trx-ledger -w /trx-ledger ledger-chain make
```

## Using your own toolchain:
```bash
make
```


# Load app onto Ledger Nano S

## Using Docker image
### Step 1 - Install virtualenv
```bash
[sudo] pip install -U setuptools
[sudo] pip install virtualenv
```

### Step 2 - Create new virtualenv
```bash
virtualenv -p python3 ledger
source ledger/bin/activate
pip install ledgerblue
```

### Step 3 - Load HEX file
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

## Using your own toolchain:

```bash
make load
```

## Load pre-compiled HEX file

### Step 1 - Install virtualenv
See step 1 above. 

### Step 2 - Create new virtualenv
See step 2 above. 

### Step 3 - Load HEX file
```bash
python -m ledgerblue.loadApp \
--targetId 0x31100003 \
--fileName NAME_OF_PRECOMPILED_HEX_HERE.hex \
--icon 0100000000ffffff0000000000fc000c0f3814c822103f101120092005400340018001800000000000 \
--curve secp256k1 \
--path "44'/195'/0'" \
--apdu \
--appName "Tron" \
--delete \
--tlv
```

Replace `NAME_OF_PRECOMPILED_HEX_HERE.hex` with the location of the precomiled hex file.

# Links
========

### [Tronscan Integration](https://github.com/tronscan/tronscan-frontend/tree/ledger)
### [Video Demo](https://www.youtube.com/watch?v=RYUiiGw-hHw&feature=youtu.be)
