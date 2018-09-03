package io.gomint.leveldb;

public class DatabaseCorruptException extends LevelDBException {

    public DatabaseCorruptException() {
    }

    public DatabaseCorruptException( String error ) {
        super( error );
    }

}