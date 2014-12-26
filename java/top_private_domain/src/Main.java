import java.net.URI;
import java.net.URISyntaxException;
import com.google.common.net.InternetDomainName;

public class Main {

    /*
     * need to import google guava
     */
    public String[] extractTopPrivateDomain (String urlString) {
        String host = null;
        String topPrivateDomain = null;
        try {
            host = new URI(urlString).getHost();
        } catch (URISyntaxException e) {
            host = null;
        }

        if (host != null) {
            try {
                InternetDomainName domainName;
                domainName = InternetDomainName.from(host);
                InternetDomainName topPrivateDomainResult = domainName.topPrivateDomain();
                topPrivateDomain = topPrivateDomainResult.toString();
            } catch (Exception e) {
                // sometimes, IP address used in URL. it does not have top-private-domain
                // if some url has public suffix doamin as hostname the topPrivateDoamin is null
                topPrivateDomain = null;
            }
        }

        String[] result = {host, topPrivateDomain};
        return result;
    }

    public static void main(String[] args) {
        Main main = new Main();
        String urlString = "http://www.test.co.kr/blahblah/test.php?param1=1&param2=2#anchor1";
        for (String r : main.extractTopPrivateDomain(urlString)) {
            System.out.println(r);
        }

    }
}
