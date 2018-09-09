#include "leveldbjni.h"

extern int register_io_gomint_leveldb_DB(JNIEnv *env);
extern int register_io_gomint_leveldb_WriteBatch(JNIEnv *env);
extern int register_io_gomint_leveldb_Iterator(JNIEnv *env);

jint throwException(JNIEnv* env, leveldb::Status status)
{
    const char* exceptionClass;

    if (status.IsNotFound())
    {
        exceptionClass = "io/gomint/leveldb/NotFoundException";
    } else if (status.IsCorruption())
    {
        exceptionClass = "io/gomint/leveldb/DatabaseCorruptException";
    } else if (status.IsIOError())
    {
        exceptionClass = "java/io/IOException";
    } else
    {
        return 0;
    }

    jclass clazz = env->FindClass(exceptionClass);
    if (!clazz)
    {
        printf("Can't find exception class %s", exceptionClass);
        return -1;
    }

    return env->ThrowNew(clazz, status.ToString().c_str());
}

jint JNI_OnLoad(JavaVM* vm, void *reserved)
{
    JNIEnv* env;
    if (vm->GetEnv((void **) &env, JNI_VERSION_1_6) != JNI_OK)
    {
        return -1;
    }

    register_io_gomint_leveldb_DB(env);
    register_io_gomint_leveldb_WriteBatch(env);
    register_io_gomint_leveldb_Iterator(env);

    return JNI_VERSION_1_6;
}