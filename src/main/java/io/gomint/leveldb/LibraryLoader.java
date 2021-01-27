package io.gomint.leveldb;

import io.gomint.nativeloader.NativeLoader;
import oshi.PlatformEnum;

public class LibraryLoader {

    public static boolean load() {
        return NativeLoader.create()
                .supports(PlatformEnum.WINDOWS, "amd64")
                .supports(PlatformEnum.LINUX, "amd64")
                .supports(PlatformEnum.LINUX, "arm")
                .supports(PlatformEnum.MACOS, "aarch64")
                .load("leveldb", LibraryLoader.class.getClassLoader());
    }

}
