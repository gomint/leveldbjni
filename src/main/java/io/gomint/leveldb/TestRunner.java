package io.gomint.leveldb;

import java.nio.file.Paths;

/**
 * @author geNAZt
 */
public class TestRunner {

    public static void main( String[] args ) {
        System.load( Paths.get( "./src/main/resources/leveldb-mcpe.dll" ).toAbsolutePath().toString() );
    }

}
