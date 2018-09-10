#include <jni.h>

#include "leveldbjni.h"

#include "leveldb/iterator.h"

static void nativeDestroy(JNIEnv* env, jclass clazz, jlong ptr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)ptr;

    delete iter;
}

static void nativeSeekToFirst(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    iter->SeekToFirst();
}

static void nativeSeekToLast(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    iter->SeekToLast();
}

static void nativeSeek(JNIEnv* env, jclass clazz, jlong iterPtr, jlong keyAddress, jint keyLength)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    iter->Seek(leveldb::Slice((const char *)keyAddress, keyLength));
}

static jboolean nativeValid(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    return iter->Valid();
}

static void nativeNext(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    iter->Next();
}

static void nativePrev(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    iter->Prev();
}

static jbyteArray nativeKey(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    leveldb::Slice key = iter->key();

    size_t len = key.size();
    jbyteArray result = env->NewByteArray(len);
    env->SetByteArrayRegion(result, 0, len, (const jbyte *) key.data());
    return result;
}

static jbyteArray nativeValue(JNIEnv* env, jclass clazz, jlong iterPtr)
{
    leveldb::Iterator* iter = (leveldb::Iterator*)iterPtr;
    leveldb::Slice value = iter->value();

    size_t len = value.size();
    jbyteArray result = env->NewByteArray(len);
    env->SetByteArrayRegion(result, 0, len, (const jbyte *) value.data());
    return result;
}

static JNINativeMethod sMethods[] =
{
        { "nativeDestroy", "(J)V", (void*) nativeDestroy },
        { "nativeSeekToFirst", "(J)V", (void*) nativeSeekToFirst },
        { "nativeSeekToLast", "(J)V", (void*) nativeSeekToLast },
        { "nativeSeek", "(JJI)V", (void*) nativeSeek },
        { "nativeValid", "(J)Z", (void*) nativeValid },
        { "nativeNext", "(J)V", (void*) nativeNext },
        { "nativePrev", "(J)V", (void*) nativePrev },
        { "nativeKey", "(J)[B", (void*) nativeKey },
        { "nativeValue", "(J)[B", (void*) nativeValue }
};

int register_io_gomint_leveldb_Iterator(JNIEnv *env) {
    jclass clazz = env->FindClass("io/gomint/leveldb/Iterator");

    if (!clazz)
    {
        printf("Can't find class io.gomint.leveldb.Iterator\n");
        return 0;
    }

    return env->RegisterNatives(clazz, sMethods, REAL_LEN(sMethods));
}