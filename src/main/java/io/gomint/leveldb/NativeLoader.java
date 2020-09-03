package io.gomint.leveldb;

import oshi.PlatformEnum;
import oshi.SystemInfo;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import static com.google.common.io.ByteStreams.copy;

/**
 * @author geNAZt
 * @version 1.0
 */
public class NativeLoader {

    private static boolean isSupported() {
        // We currently only support windows and linux x64
        return ( SystemInfo.getCurrentPlatformEnum() == PlatformEnum.WINDOWS ||
                SystemInfo.getCurrentPlatformEnum() == PlatformEnum.LINUX ) &&
                "amd64".equals( System.getProperty( "os.arch" ) );
    }

    public static boolean load() {
        if ( !isSupported() ) {
            return false;
        }

        String prefix = SystemInfo.getCurrentPlatformEnum() == PlatformEnum.WINDOWS ? "" : "lib";
        String fullName = prefix + "leveldb-mcpe";

        // Load needed libs
        String ending = SystemInfo.getCurrentPlatformEnum() == PlatformEnum.WINDOWS ? ".dll" : ".so";
        try ( InputStream soFile = getInput( fullName, ending ) ) {
            if ( soFile == null ) {
                return false;
            }

            // Else we will create and copy it to a temp file
            File temp = File.createTempFile( fullName, ending );

            // Don't leave cruft on filesystem
            temp.deleteOnExit();

            try ( OutputStream outputStream = new FileOutputStream( temp ) ) {
                copy( soFile, outputStream );
            }

            System.load( temp.getPath() );
            return true;
        } catch ( IOException ex ) {
            // Can't write to tmp?
        } catch ( UnsatisfiedLinkError ex ) {
            System.out.println( "Could not load native library: " + ex.getMessage() );
        }

        return false;
    }

    private static InputStream getInput( String name, String ending ) {
        InputStream in = NativeLoader.class.getClassLoader().getResourceAsStream( name + ending );
        if ( in == null ) {
            try {
                in = new FileInputStream( "./src/main/resources/" + name + ending );
            } catch ( FileNotFoundException e ) {
                // Ignored -.-
            }
        }

        return in;
    }

}
