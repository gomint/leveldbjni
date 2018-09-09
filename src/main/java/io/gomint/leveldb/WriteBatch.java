package io.gomint.leveldb;

import io.netty.buffer.ByteBuf;

public class WriteBatch extends NativeObject {

    public WriteBatch() {
        // Create new leveldb::WriteBatch native object
        super( nativeCreate() );
    }

    @Override
    protected void closeNativeObject( long ptr ) {
        nativeDestroy( ptr );
    }

    public void delete( ByteBuf key ) {
        // Smoke tests
        if ( key == null ) {
            throw new NullPointerException( "key" );
        }

        key.memoryAddress();
        assertOpen( "WriteBatch is closed" );

        // Get memory address and pos
        nativeDelete( mPtr, key.memoryAddress() + key.readerIndex(), key.readableBytes() );
    }

    public void put( ByteBuf key, ByteBuf value ) {
        // Smoke tests
        if ( key == null ) {
            throw new NullPointerException( "key" );
        }

        if ( value == null ) {
            throw new NullPointerException( "value" );
        }

        key.memoryAddress();
        value.memoryAddress();

        assertOpen( "WriteBatch is closed" );

        nativePut( mPtr, key.memoryAddress() + key.readerIndex(), key.readableBytes(), value.memoryAddress() + value.readerIndex(), value.readableBytes() );
    }

    public void clear() {
        assertOpen( "WriteBatch is closed" );
        nativeClear( mPtr );
    }

    private static native long nativeCreate();

    private static native void nativeDestroy( long ptr );

    private static native void nativeDelete( long ptr, long key, int keyLength );

    private static native void nativePut( long ptr, long key, int keyLength, long value, int valueLength );

    private static native void nativeClear( long ptr );
}