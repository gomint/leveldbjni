cmake_minimum_required(VERSION 3.10)
project(leveldb-mcpe)

set(JAVA_AWT_LIBRARY NotNeeded)
set(JAVA_JVM_LIBRARY NotNeeded)

find_package(JNI REQUIRED)

find_library(LEVELDB_LIBRARY
  NAMES leveldb
  HINTS "${PROJECT_SOURCE_DIR}/../../../deps/leveldb/Release/"
  REQUIRED
)

set(LIBS ${LIBS} ${LEVELDB_LIBRARY})
message("${LIBS}")

add_library(leveldb-mcpe SHARED leveldbjni.cpp io_gomint_leveldb_DB.cpp io_gomint_leveldb_Iterator.cpp io_gomint_leveldb_WriteBatch.cpp)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

target_include_directories(leveldb-mcpe PUBLIC "${JNI_INCLUDE_DIRS}" "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/../../../deps/leveldb/include")
target_link_libraries(leveldb-mcpe ${LIBS})

install(TARGETS leveldb-mcpe DESTINATION bin)