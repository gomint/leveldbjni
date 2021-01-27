#!/usr/bin/env bash

get_zip() {
  wget $1 --no-check-certificate -q -O temp.zip || exit 1
  7z x -y temp.zip || exit 1
  rm temp.zip || exit 1
}

LEVELDB_MCPE_VER=84348b9b826cc280cde659185695d2170b54824c
DEPS_DIR=$PWD/deps

echo $DEPS_DIR
rm -rf $DEPS_DIR
mkdir $DEPS_DIR
cd $DEPS_DIR

echo "Downloading deps..."

get_zip https://github.com/pmmp/leveldb/archive/$LEVELDB_MCPE_VER.zip

rm -rf leveldb
mv leveldb-$LEVELDB_MCPE_VER leveldb

cd leveldb
cmake -G "Unix Makefiles" \
 -DCMAKE_PREFIX_PATH="$DEPS_DIR" \
 -DCMAKE_INSTALL_PREFIX="$DEPS_DIR" \
 -DBUILD_SHARED_LIBS=OFF \
 -DLEVELDB_BUILD_BENCHMARKS=OFF \
 -DLEVELDB_BUILD_TESTS=OFF \
 -DCMAKE_POSITION_INDEPENDENT_CODE=ON || exit 1
make
cd ../../

cd src/main/c/
cmake -G "Unix Makefiles" || exit 1
make

