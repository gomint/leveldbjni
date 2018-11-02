package io.gomint.test.leveldb;

import io.gomint.leveldb.DB;
import io.gomint.leveldb.NativeLoader;
import org.junit.Test;

import java.io.File;

/**
 * @author geNAZt
 * @version 1.0
 */
public class OpenCloseTest {

    static {
        NativeLoader.load();
    }

    @Test
    public void testOpenClose() {
        // Open DB
        DB db = new DB( new File( "db" ) );
        db.open();

        // Close DB
        db.close();

        // Check if DB is unlocked correct
        db = new DB( new File( "db" ) );
        db.open(); // If the database did not close before we get a exception here that the db is locked

        // Close DB
        db.close();
    }

}
