#include <jni.h>

#include <stdio.h>
#include <stdlib.h>

#include "leveldbjni.h"

#include "leveldb/write_batch.h"

static jlong nativeCreate(JNIEnv* env, jclass clazz)
{
    leveldb::WriteBatch* batch = new leveldb::WriteBatch();
    return (jlong) batch;
}

static void nativeDestroy(JNIEnv* env, jclass clazz, jlong ptr)
{
    leveldb::WriteBatch* batch = (leveldb::WriteBatch*) ptr;
    delete batch;
}

static void nativeDelete(JNIEnv* env, jclass clazz, jlong ptr, jlong keyMemory, jint keyLength)
{
    leveldb::WriteBatch* batch = (leveldb::WriteBatch*) ptr;

    const char *bytes = (const char *) keyMemory;
    batch->Delete(leveldb::Slice(bytes, keyLength));
}

static void nativePut(JNIEnv* env, jclass clazz, jlong ptr, jlong keyMemory, jint keyLength, jlong valMemory, jint valLength)
{
    leveldb::WriteBatch* batch = (leveldb::WriteBatch*) ptr;

    const char *keyBytes = (const char *) keyMemory;
    const char *valBytes = (const char *) valMemory;

    batch->Put(leveldb::Slice(keyBytes, keyLength), leveldb::Slice(keyBytes, valLength));
}

static jlong nativeSize(JNIEnv* env, jclass clazz, jlong ptr)
{
    leveldb::WriteBatch* batch = (leveldb::WriteBatch*) ptr;
    return (jlong) batch->ApproximateSize();
}

static void nativeClear(JNIEnv* env, jclass clazz, jlong ptr)
{
    leveldb::WriteBatch* batch = (leveldb::WriteBatch*) ptr;
    batch->Clear();
}

static JNINativeMethod sMethods[] =
{
        { "nativeCreate", "()J", (void*) nativeCreate },
        { "nativeDestroy", "(J)V", (void*) nativeDestroy },
        { "nativeDelete", "(JJI)V", (void*) nativeDelete },
        { "nativePut", "(JJIJI)V", (void*) nativePut },
        { "nativeClear", "(J)V", (void*) nativeClear },
        { "nativeSize", "(J)J", (void*) nativeSize }
};

int register_io_gomint_leveldb_WriteBatch(JNIEnv *env) {
    jclass clazz = env->FindClass("io/gomint/leveldb/WriteBatch");

    if (!clazz)
    {
        printf("Can't find class io.gomint.leveldb.WriteBatch\n");
        return 0;
    }

    return env->RegisterNatives(clazz, sMethods, REAL_LEN(sMethods));
}