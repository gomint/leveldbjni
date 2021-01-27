module gomint.leveldb {
    requires io.netty.buffer;
    requires gomint.nativeloader;
    requires com.github.oshi;

    exports io.gomint.leveldb;
}