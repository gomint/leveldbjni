package io.gomint.leveldb;

import io.netty.buffer.ByteBuf;

import java.io.File;

public class DB extends NativeObject {

    public abstract static class Snapshot extends NativeObject {
        Snapshot( long ptr ) {
            super( ptr );
        }
    }

    private final File mPath;
    private boolean mDestroyOnClose = false;

    public DB( File path ) {
        super();

        if ( path == null ) {
            throw new NullPointerException();
        }

        mPath = path;
    }

    public void open() {
        mPtr = nativeOpen( mPath.getAbsolutePath() );
    }

    @Override
    protected void closeNativeObject( long ptr ) {
        nativeClose( ptr );

        if ( mDestroyOnClose ) {
            destroy( mPath );
        }
    }

    public void put( ByteBuf key, ByteBuf value ) {
        assertOpen( "Database is closed" );
        if ( key == null ) {
            throw new NullPointerException( "key" );
        }

        if ( value == null ) {
            throw new NullPointerException( "value" );
        }

        key.memoryAddress();
        value.memoryAddress();

        nativePut( mPtr, key.memoryAddress() + key.readerIndex(), key.readableBytes(),
                value.memoryAddress() + value.readerIndex(), value.readableBytes() );

        // Modify input bytebufs
        key.readerIndex( key.readerIndex() + key.readableBytes() );
        value.readerIndex( value.readerIndex() + value.readableBytes() );
    }

    public byte[] get( ByteBuf key ) {
        return get( null, key );
    }

    public byte[] get( Snapshot snapshot, ByteBuf key ) {
        assertOpen( "Database is closed" );
        if ( key == null ) {
            throw new NullPointerException();
        }

        key.memoryAddress();

        byte[] val = nativeGet( mPtr, snapshot != null ? snapshot.getPtr() : 0, key.memoryAddress() + key.readerIndex(), key.readableBytes() );
        key.readerIndex( key.readerIndex() + key.readableBytes() );
        return val;
    }

    public void delete( ByteBuf key ) {
        assertOpen( "Database is closed" );
        if ( key == null ) {
            throw new NullPointerException();
        }

        key.memoryAddress();

        nativeDelete( mPtr, key.memoryAddress() + key.readerIndex(), key.readableBytes() );
        key.readerIndex( key.readerIndex() + key.readableBytes() );
    }

    public void write( WriteBatch batch ) {
        assertOpen( "Database is closed" );
        if ( batch == null ) {
            throw new NullPointerException();
        }

        nativeWrite( mPtr, batch.getPtr() );
    }

    public Iterator iterator() {
        return iterator( null );
    }

    public Iterator iterator( final Snapshot snapshot ) {
        assertOpen( "Database is closed" );

        ref();

        if ( snapshot != null ) {
            snapshot.ref();
        }

        return new Iterator( nativeIterator( mPtr, snapshot != null ? snapshot.getPtr() : 0 ) ) {
            @Override
            protected void closeNativeObject( long ptr ) {
                super.closeNativeObject( ptr );
                if ( snapshot != null ) {
                    snapshot.unref();
                }

                DB.this.unref();
            }
        };
    }

    public Snapshot getSnapshot() {
        assertOpen( "Database is closed" );
        ref();
        return new Snapshot( nativeGetSnapshot( mPtr ) ) {
            protected void closeNativeObject( long ptr ) {
                nativeReleaseSnapshot( DB.this.getPtr(), getPtr() );
                DB.this.unref();
            }
        };
    }

    public void destroy() {
        mDestroyOnClose = true;
        if ( getPtr() == 0 ) {
            destroy( mPath );
        }
    }

    public static void destroy( File path ) {
        nativeDestroy( path.getAbsolutePath() );
    }

    private static native long nativeOpen( String dbpath );

    private static native void nativeClose( long dbPtr );

    private static native void nativePut( long dbPtr, long keyAddress, int keyLength, long valueAddress, int valueLength );

    private static native byte[] nativeGet( long dbPtr, long snapshotPtr, long keyAddress, int keyLength );

    private static native void nativeDelete( long dbPtr, long keyAddress, int keyLength );

    private static native void nativeWrite( long dbPtr, long batchPtr );

    private static native void nativeDestroy( String dbpath );

    private static native long nativeIterator( long dbPtr, long snapshotPtr );

    private static native long nativeGetSnapshot( long dbPtr );

    private static native void nativeReleaseSnapshot( long dbPtr, long snapshotPtr );

}