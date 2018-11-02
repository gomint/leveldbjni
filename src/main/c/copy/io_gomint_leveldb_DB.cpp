#include <string.h>
#include <jni.h>

#include <stdio.h>
#include <stdlib.h>

#include "leveldbjni.h"

#include "leveldb/db.h"
#include "leveldb/write_batch.h"

#include "leveldb/zlib_compressor.h"
#include "leveldb/filter_policy.h"
#include "leveldb/cache.h"
#include "leveldb/decompress_allocator.h"
#include "leveldb/env.h"

static leveldb::ReadOptions readOptions;

class NullLogger : public leveldb::Logger
{
public:
    void Logv(const char*, va_list) override
    {
    }
};

static jlong nativeOpen(JNIEnv* env, jclass clazz, jstring dbpath)
{
    const char *path = env->GetStringUTFChars(dbpath, 0);

    leveldb::DB* db;
    leveldb::Options options;

    options.filter_policy = leveldb::NewBloomFilterPolicy(10);
    options.block_cache = leveldb::NewLRUCache(40 * 1024 * 1024);
    options.write_buffer_size = 4 * 1024 * 1024;
    options.info_log = new NullLogger();
    options.compressors[0] = new leveldb::ZlibCompressorRaw(-1);
    options.compressors[1] = new leveldb::ZlibCompressor();
    options.create_if_missing = true;

    readOptions.decompress_allocator = new leveldb::DecompressAllocator();

    leveldb::Status status = leveldb::DB::Open(options, path, &db);
    env->ReleaseStringUTFChars(dbpath, path);

    if (!status.ok())
    {
        throwException(env, status);
    }

    return (jlong) db;
}

static void nativeClose(JNIEnv* env, jclass clazz, jlong dbPtr)
{
    leveldb::DB* db = (leveldb::DB*) dbPtr;
    if (db)
    {
        delete db;
    }
}

static jbyteArray nativeGet(JNIEnv * env, jclass clazz, jlong dbPtr, jlong snapshotPtr, jlong keyAddress, jint keyLength)
{
    leveldb::DB* db = (leveldb::DB*) dbPtr;
    readOptions.snapshot = (leveldb::Snapshot*) snapshotPtr;

    jbyteArray result;

    leveldb::Slice key = leveldb::Slice((const char *)keyAddress, keyLength);
    leveldb::Iterator* iter = db->NewIterator(readOptions);
    iter->Seek(key);

    if (iter->Valid() && key == iter->key())
    {
        leveldb::Slice value = iter->value();
        size_t len = value.size();
        result = env->NewByteArray(len);
        env->SetByteArrayRegion(result, 0, len, (const jbyte *) value.data());
    } else
    {
        result = NULL;
    }

    delete iter;
    return result;
}

static void nativePut(JNIEnv *env, jclass clazz, jlong dbPtr, jlong keyAddress, jint keyLength, jlong valueAddress, jint valueLength)
{
    leveldb::DB* db = (leveldb::DB*)(dbPtr);

    leveldb::Status status = db->Put(leveldb::WriteOptions(),
    leveldb::Slice((const char *) keyAddress, keyLength),
    leveldb::Slice((const char *) valueAddress, valueLength));

    if (!status.ok())
    {
        throwException(env, status);
    }
}

static void nativeDelete(JNIEnv *env, jclass clazz, jlong dbPtr, jlong keyAddress, jint keyLength)
{
    leveldb::DB* db = (leveldb::DB*)(dbPtr);
    leveldb::Status status = db->Delete(leveldb::WriteOptions(), leveldb::Slice((const char *) keyAddress, keyLength));

    if (!status.ok())
    {
        throwException(env, status);
    }
}

static void nativeWrite(JNIEnv *env, jclass clazz, jlong dbPtr, jlong batchPtr)
{
    leveldb::DB* db = (leveldb::DB*)(dbPtr);

    leveldb::WriteBatch *batch = (leveldb::WriteBatch *) batchPtr;
    leveldb::Status status = db->Write(leveldb::WriteOptions(), batch);

    if (!status.ok())
    {
        throwException(env, status);
    }
}

static jlong nativeIterator(JNIEnv* env, jclass clazz, jlong dbPtr, jlong snapshotPtr)
{
    leveldb::DB* db = (leveldb::DB*)(dbPtr);
    leveldb::ReadOptions options = leveldb::ReadOptions();
    options.snapshot = (leveldb::Snapshot*)(snapshotPtr);

    leveldb::Iterator *iter = db->NewIterator(options);
    return (jlong) iter;
}

static jlong nativeGetSnapshot(JNIEnv *env, jclass clazz, jlong dbPtr)
{
    leveldb::DB* db = (leveldb::DB*)(dbPtr);
    const leveldb::Snapshot* snapshot = db->GetSnapshot();
    return (jlong) snapshot;
}

static void nativeReleaseSnapshot(JNIEnv *env, jclass clazz, jlong dbPtr, jlong snapshotPtr)
{
    leveldb::DB* db = (leveldb::DB*)(dbPtr);
    const leveldb::Snapshot *snapshot = (leveldb::Snapshot*)(snapshotPtr);
    db->ReleaseSnapshot(snapshot);
}

static void nativeDestroy(JNIEnv *env, jclass clazz, jstring dbpath)
{
    const char* path = env->GetStringUTFChars(dbpath,0);
    leveldb::Options options;
    options.create_if_missing = true;
    leveldb::Status status = DestroyDB(path, options);

    if (!status.ok())
    {
        throwException(env, status);
    }
}

static JNINativeMethod sMethods[] =
{
        { "nativeOpen", "(Ljava/lang/String;)J", (void*) nativeOpen },
        { "nativeClose", "(J)V", (void*) nativeClose },
        { "nativeGet", "(JJJI)[B", (void*) nativeGet },
        { "nativePut", "(JJIJI)V", (void*) nativePut },
        { "nativeDelete", "(JJI)V", (void*) nativeDelete },
        { "nativeWrite", "(JJ)V", (void*) nativeWrite },
        { "nativeIterator", "(JJ)J", (void*) nativeIterator },
        { "nativeGetSnapshot", "(J)J", (void*) nativeGetSnapshot },
        { "nativeReleaseSnapshot", "(JJ)V", (void*) nativeReleaseSnapshot },
        { "nativeDestroy", "(Ljava/lang/String;)V", (void*) nativeDestroy }
};

int
register_io_gomint_leveldb_DB(JNIEnv *env) {
    jclass clazz = env->FindClass("io/gomint/leveldb/DB");

    if (!clazz)
    {
        printf("Can't find class io.gomint.leveldb.DB\n");
        return 0;
    }

    return env->RegisterNatives(clazz, sMethods, REAL_LEN(sMethods));
}