Java Keystore SSL/HTTPS Wildcard Tests
======================================
SSL Utilities to generate wildcard certs.
This creates SSL certificate with wildcards in the Subject Alternative Name
to support the [UAA identity zones](https://github.com/cloudfoundry/uaa) (multi tenancy)

##Requirements

* Java 7+
* Git 1.8+
* OpenSSL 1.0.1f+ 

##Cleaning up the repo
If you have ran samples or generated certificates before, you can clean them up
```
git clean -fd
```

##Generating Wildcard Certificate (and certificate authority)
```
ssl-certificate/run-commands.sh
```
Generates the following files (the command is idempotent, rerun it and it generates a new set)

1. cacert.jks - a Java keystore containing the Certificate Authority (CA) certificate
2. private/cakey.pem - the private key for the CA certificate
3. cacert.pem - The CA certificate in PEM format
4. requests/webserverkey-pkcs8.pem - server private key, no passphrase
5. requests/webserverkey.pem - server private key, passphrase protected
6. requests/webservercert.csr - certificate signing requests - contains the Subject Alternative Names
7. requests/webservercert.pem - server signed certificate, signed by the generated CA

And we have the following wildcards covered

1.  ```*.127.0.0.1.xip.io```
2.  ```*.uaa.127.0.0.1.xip.io```
3.  ```*.login.127.0.0.1.xip.io```

##Start up the server
```
./gradlew server
```
This starts up a server on port 8443, that uses the webservercert.pem certificate

##Client Examples

###Failing because we can't trust
```
curl -v https://uaa.127.0.0.1.xip.io:8443
```

###Succeed - access the UAA
```
curl -v --cacert ssl-certificate/cacert.pem https://uaa.127.0.0.1.xip.io:8443
```

###Succeed - access the login server
```
curl -v --cacert ssl-certificate/cacert.pem https://login.127.0.0.1.xip.io:8443
```

###Succeed - access a deployed app
```
curl -v --cacert ssl-certificate/cacert.pem https://anyapp.127.0.0.1.xip.io:8443
```

###Succeed - access a zone in the UAA subdomain
```
curl -v --cacert ssl-certificate/cacert.pem https://zone1.uaa.127.0.0.1.xip.io:8443
```

###Succeed - access a zone in the login subdomain
```
curl -v --cacert ssl-certificate/cacert.pem https://zone1.login.127.0.0.1.xip.io:8443
```

##Java Client Test
```
./gradlew client -Pnotrust -Purl=https://www.google.com
```
Uses the default Java trust store to test an SSL connection. Performs simple GET.
Removing the ```notrust``` flag, will enable the ```/ssl-certificate/cacert.jks``` trust store.

###Testing out the Java Client against the Java Server
Because gradle locks the cache, we need a new cache directory
```
GRADLE_USER_HOME=/tmp/gradle ./gradlew client -Purl=https://zone1.login.127.0.0.1.xip.io:8443
```


##Java Samples

###Successful connection
```
[INFO]  Received host address https://www.google.com
[INFO]  Setting connection timeout to 5 second(s).
[INFO]  Trying to connect to https://www.google.com
[INFO]  Great! It worked.
```

###Failed connection
```
[INFO]  Received host address https://registry.npmjs.org/sailthru-client
[INFO]  Setting connection timeout to 5 second(s).
[INFO]  Trying to connect to https://registry.npmjs.org/sailthru-client
[INFO]  Could not connect to the host address https://registry.npmjs.org/sailthru-client
[INFO]  The error is: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
[INFO]  Here are the details:
[SEVERE]        sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
Exception in thread "main" java.lang.RuntimeException: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
        at Test.main(Test.java:61)
Caused by: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
        at sun.security.ssl.Alerts.getSSLException(Alerts.java:192)
        at sun.security.ssl.SSLSocketImpl.fatal(SSLSocketImpl.java:1868)
        at sun.security.ssl.Handshaker.fatalSE(Handshaker.java:276)
        at sun.security.ssl.Handshaker.fatalSE(Handshaker.java:270)
        at sun.security.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1338)
        at sun.security.ssl.ClientHandshaker.processMessage(ClientHandshaker.java:154)
        at sun.security.ssl.Handshaker.processLoop(Handshaker.java:868)
        at sun.security.ssl.Handshaker.process_record(Handshaker.java:804)
        at sun.security.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:998)
        at sun.security.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1294)
        at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1321)
        at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1305)
        at sun.net.www.protocol.https.HttpsClient.afterConnect(HttpsClient.java:515)
        at sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:185)
        at sun.net.www.protocol.http.HttpURLConnection.getInputStream(HttpURLConnection.java:1299)
        at sun.net.www.protocol.https.HttpsURLConnectionImpl.getInputStream(HttpsURLConnectionImpl.java:254)
        at Test.main(Test.java:45)
Caused by: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
        at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:385)
        at sun.security.validator.PKIXValidator.engineValidate(PKIXValidator.java:292)
        at sun.security.validator.Validator.validate(Validator.java:260)
        at sun.security.ssl.X509TrustManagerImpl.validate(X509TrustManagerImpl.java:326)
        at sun.security.ssl.X509TrustManagerImpl.checkTrusted(X509TrustManagerImpl.java:231)
        at sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(X509TrustManagerImpl.java:126)
        at sun.security.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1320)
        ... 12 more
Caused by: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
        at sun.security.provider.certpath.SunCertPathBuilder.engineBuild(SunCertPathBuilder.java:196)
        at java.security.cert.CertPathBuilder.build(CertPathBuilder.java:268)
        at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:380)
        ... 18 more
```

## References

* http://blog.endpoint.com/2013/10/ssl-certificate-sans-and-multi-level.html
* http://acidx.net/wordpress/2012/09/creating-a-certification-authority-and-a-server-certificate-on-ubuntu/
* http://tools.ietf.org/html/rfc2818

```Text
   If a subjectAltName extension of type dNSName is present, that MUST
   be used as the identity. Otherwise, the (most specific) Common Name
   field in the Subject field of the certificate MUST be used. Although
   the use of the Common Name is existing practice, it is deprecated and
   Certification Authorities are encouraged to use the dNSName instead.
```