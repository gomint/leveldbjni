cmake_minimum_required(VERSION 3.10)
project(leveldb-mcpe LANGUAGES C CXX)

# C standard can be overridden when this is used as a sub-project.
if(NOT CMAKE_C_STANDARD)
  # This project can use C11, but will gracefully decay down to C89.
  set(CMAKE_C_STANDARD 11)
  set(CMAKE_C_STANDARD_REQUIRED OFF)
  set(CMAKE_C_EXTENSIONS OFF)
endif(NOT CMAKE_C_STANDARD)

# C++ standard can be overridden when this is used as a sub-project.
if(NOT CMAKE_CXX_STANDARD)
  # This project requires C++11.
  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif(NOT CMAKE_CXX_STANDARD)

set(JAVA_AWT_LIBRARY NotNeeded)
set(JAVA_JVM_LIBRARY NotNeeded)

find_package(JNI REQUIRED)

find_library(ZLIB_LIBRARY
  NAMES zlibstatic z
  HINTS "${PROJECT_SOURCE_DIR}/../../../deps/zlib/Release/"
  REQUIRED
)

find_library(LEVELDB_LIBRARY
  NAMES leveldb
  HINTS "${PROJECT_SOURCE_DIR}/../../../deps/leveldb/Release/" "${PROJECT_SOURCE_DIR}/../../../deps/leveldb/"
  REQUIRED
)

set(LIBS ${LIBS} ${LEVELDB_LIBRARY} ${ZLIB_LIBRARY})

add_library(leveldb-mcpe SHARED leveldbjni.cpp io_gomint_leveldb_DB.cpp io_gomint_leveldb_Iterator.cpp io_gomint_leveldb_WriteBatch.cpp)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

target_include_directories(leveldb-mcpe PUBLIC "${JNI_INCLUDE_DIRS}" "${PROJECT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/../../../deps/leveldb/include")
target_link_libraries(leveldb-mcpe ${LIBS})

install(TARGETS leveldb-mcpe DESTINATION bin)
