#!/bin/bash
JAVA_HOME=/usr/lib/jvm/java-11-oracle

CWD=$(pwd)
CXX="g++ -std=c++11 -s -shared -fPIC -fno-builtin-memcmp -DOS_LINUX -DLEVELDB_PLATFORM_POSIX -DLEVELDB_ATOMIC_PRESENT -DNDEBUG -O2 -DDLLX= -pthread -I$JAVA_HOME/include/ -I$JAVA_HOME/include/linux/ -I$CWD/leveldb-mcpe/ -I$CWD/leveldb-mcpe/include/"

echo $CXX
$CXX leveldb-mcpe/db/builder.cc      leveldb-mcpe/db/c.cc\
     leveldb-mcpe/db/db_impl.cc      leveldb-mcpe/db/db_iter.cc\
     leveldb-mcpe/db/dbformat.cc     leveldb-mcpe/db/filename.cc\
     leveldb-mcpe/db/log_reader.cc   leveldb-mcpe/db/log_writer.cc\
     leveldb-mcpe/db/memtable.cc     leveldb-mcpe/db/repair.cc\
     leveldb-mcpe/db/table_cache.cc  leveldb-mcpe/db/version_edit.cc\
     leveldb-mcpe/db/version_set.cc  leveldb-mcpe/db/write_batch.cc\
     leveldb-mcpe/db/snappy_compressor.cc\
     leveldb-mcpe/db/zlib_compressor.cc\
     leveldb-mcpe/db/zopfli_compressor.cc\
     leveldb-mcpe/db/zstd_compressor.cc\
	 \
     leveldb-mcpe/table/block.cc     leveldb-mcpe/table/block_builder.cc\
     leveldb-mcpe/table/filter_block.cc\
     leveldb-mcpe/table/iterator.cc  leveldb-mcpe/table/merger.cc\
     leveldb-mcpe/table/table.cc     leveldb-mcpe/table/table_builder.cc\
     leveldb-mcpe/table/two_level_iterator.cc\
     leveldb-mcpe/table/format.cc\
     \
     leveldb-mcpe/util/arena.cc      leveldb-mcpe/util/bloom.cc\
     leveldb-mcpe/util/cache.cc      leveldb-mcpe/util/coding.cc\
     leveldb-mcpe/util/comparator.cc leveldb-mcpe/util/crc32c.cc\
     leveldb-mcpe/util/env.cc        leveldb-mcpe/util/env_posix.cc\
     leveldb-mcpe/util/filter_policy.cc\
     leveldb-mcpe/util/hash.cc\
     leveldb-mcpe/util/histogram.cc  leveldb-mcpe/util/logging.cc\
     leveldb-mcpe/util/options.cc    leveldb-mcpe/util/status.cc\
     \
     leveldb-mcpe/port/port_posix.cc leveldb-mcpe/port/port_posix_sse.cc\
	 \
	 leveldb-mcpe/io_gomint_leveldb_DB.cpp leveldb-mcpe/io_gomint_leveldb_Iterator.cpp leveldb-mcpe/io_gomint_leveldb_WriteBatch.cpp leveldb-mcpe/leveldbjni.cpp -o ../resources/leveldb-mcpe.so -lz
