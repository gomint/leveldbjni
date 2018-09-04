#!/bin/sh
CWD=$(pwd)

# First we start by this: you NEED cygwin with installed x86_64-w64-mingw32-g++ for this to work
CXX="g++"

# We compile with c++0x because leveldb uses it as preferred language level
CXX="$CXX -std=c++11"

# Some shared library switches
CXX="$CXX -s -shared -static -fPIC -static-libgcc -static-libstdc++"

# This build should use the libc memcmp instead of the builtin one
CXX="$CXX -fno-builtin-memcmp"

# Since we use a "emulated" windows build chain we need to define that we are windows 7
CXX="$CXX -D_WIN32_WINNT=0x0600 -D_WIN32_WINDOWS=0x0600"

# Now some leveldb config (telling we are windows)
CXX="$CXX -DOS_WIN -DOS_WINDOWS -DWIN32 -DNDEBUG -DLEVELDB_ATOMIC_PRESENT -DDLLX= -pthread -DLEVELDB_MINGW"

# Some general improvements (seems buggy)
CXX="$CXX -O2"

# Includes
CXX="$CXX -I$JAVA_HOME/include/ -I$JAVA_HOME/include/win32/ -I$CWD/leveldb-mcpe/ -I$CWD/leveldb-mcpe/include/"

# Verify that the built cmd is correct
echo $CXX

# Build the windows version
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
     leveldb-mcpe/util/env.cc        leveldb-mcpe/util/env_win.cc\
     leveldb-mcpe/util/filter_policy.cc\
     leveldb-mcpe/util/hash.cc\
     leveldb-mcpe/util/histogram.cc  leveldb-mcpe/util/logging.cc\
	 leveldb-mcpe/util/win_logger.cc leveldb-mcpe/util/options.cc\
	 leveldb-mcpe/util/status.cc\
     \
     leveldb-mcpe/port/port_win.cc leveldb-mcpe/port/port_posix_sse.cc\
	 \
	 io_gomint_leveldb_DB.cpp io_gomint_leveldb_Iterator.cpp io_gomint_leveldb_WriteBatch.cpp leveldbjni.cpp -o ../resources/leveldb-mcpe.dll -lz