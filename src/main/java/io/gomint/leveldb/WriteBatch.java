package io.gomint.leveldb;

import io.netty.buffer.ByteBuf;

import java.util.ArrayList;
import java.util.List;

public class WriteBatch extends NativeObject {

    private List<ByteBuf> usedByteBuffers = new ArrayList<>();

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

        // Hold reference
        this.usedByteBuffers.add( key );

        // Get memory address and pos
        nativeDelete( mPtr, key.memoryAddress() + key.readerIndex(), key.readableBytes() );
        key.readerIndex( key.readerIndex() + key.readableBytes() );
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

        // Hold reference
        this.usedByteBuffers.add( key );
        this.usedByteBuffers.add( value );

        nativePut( mPtr, key.memoryAddress() + key.readerIndex(), key.readableBytes(), value.memoryAddress() + value.readerIndex(), value.readableBytes() );
        key.readerIndex( key.readerIndex() + key.readableBytes() );
        value.readerIndex( value.readerIndex() + value.readableBytes() );
    }

    public long size() {
        assertOpen( "WriteBatch is closed" );
        return nativeSize( mPtr );
    }

    public void clear() {
        assertOpen( "WriteBatch is closed" );
        nativeClear( mPtr );

        // Release all netty byte buffers
        for ( ByteBuf buffer : this.usedByteBuffers ) {
            buffer.release();
        }

        this.usedByteBuffers.clear();
    }

    private static native long nativeCreate();

    private static native void nativeDestroy( long ptr );

    private static native void nativeDelete( long ptr, long key, int keyLength );

    private static native void nativePut( long ptr, long key, int keyLength, long value, int valueLength );

    private static native void nativeClear( long ptr );

    private static native long nativeSize( long ptr );

}