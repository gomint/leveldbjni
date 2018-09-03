#ifndef LEVELDBJNI_H_
#define LEVELDBJNI_H_

#include <jni.h>
#include "leveldb/status.h"

#define REAL_LEN(x) ((int) (sizeof(x) / sizeof((x)[0])))

jint throwException(JNIEnv* env, leveldb::Status status);

#endif /* LEVELDBJNI_H_ */