#!/bin/sh
mkdir -p protocol/googleapis/google/api
mkdir proto
git clone https://github.com/tronprotocol/protocol.git protocol/tron

curl https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto > protocol/googleapis/google/api/annotations.proto
curl https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto > protocol/googleapis/google/api/http.proto

python -m grpc_tools.protoc -I./protocol/tron -I./protocol/googleapis --python_out=./proto ./protocol/tron/api/*.proto ./protocol/tron/core/*.proto ./protocol/googleapis/google/api/*.proto 
python -m grpc_tools.protoc -I./protocol/tron -I./protocol/googleapis --python_out=./proto --grpc_python_out=./proto ./protocol/tron/api/*.proto
 