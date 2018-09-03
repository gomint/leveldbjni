package io.gomint.leveldb;

public class NotFoundException extends LevelDBException {

    public NotFoundException() {
    }

    public NotFoundException( String error ) {
        super( error );
    }

}