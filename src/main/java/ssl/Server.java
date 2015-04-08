package ssl;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.Channel;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.handler.ssl.SslContext;
import joptsimple.BuiltinHelpFormatter;
import joptsimple.OptionException;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import joptsimple.OptionSpec;

import java.io.File;
import java.io.IOException;
import java.util.List;

public class Server {

    static OptionParser parser = new OptionParser();

    public static void usage() throws IOException {
        parser.formatHelpWith(new BuiltinHelpFormatter(120, 2));
        parser.printHelpOn(System.err);
    }

    public static void main(String... args) throws Exception {

        OptionSpec<File>   key =  parser.accepts("key", "Private Key used with SSL Certificate").withRequiredArg().ofType(File.class);
        OptionSpec<File>   cert=  parser.accepts("certificate", "SSL Certificate for the Server").withRequiredArg().ofType(File.class);
        OptionSpec<String> pass =  parser.accepts("pass", "Passphrase for private key").withOptionalArg().ofType(String.class).defaultsTo("password");
        OptionSpec<Integer>port = parser.accepts("port", "TCP Listen Port").withOptionalArg().ofType(Integer.TYPE).defaultsTo(8443);
        OptionSet options = null;
        try {
            options = parser.parse(args);
        } catch (OptionException x) {
            usage();
            System.exit(1);
        }

        int sslPort = options.valueOf(port);
        File sslKey = options.valueOf(key);
        File sslCert = options.valueOf(cert);
        String passphrase = options.valueOf(pass);

        SslContext sslContext = SslContext.newServerContext(sslCert, sslKey, passphrase);
        EventLoopGroup bossGroup = new NioEventLoopGroup(1);
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        try {
            ServerBootstrap b = new ServerBootstrap();
            b.group(bossGroup, workerGroup)
                .channel(NioServerSocketChannel.class)
                .handler(new LoggingHandler(LogLevel.INFO))
                .childHandler(new HttpsServerInitializer(sslContext));
            Channel ch = b.bind(sslPort).sync().channel();
            System.out.println("Open your web browser and navigate to https://127.0.0.1:" + sslPort + '/');
            ch.closeFuture().sync();
        } finally {
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
        }

    }

}
