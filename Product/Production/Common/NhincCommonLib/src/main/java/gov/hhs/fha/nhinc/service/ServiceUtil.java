package gov.hhs.fha.nhinc.service;

import gov.hhs.fha.nhinc.properties.PropertyAccessException;
import gov.hhs.fha.nhinc.properties.PropertyAccessor;
import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *
 * @author Neil Webb
 */
public class ServiceUtil
{
    private static final String PROPERTIES_FILE = "connectCommon";
    private static final String PROPERTY_KEY_WSDL_PATH = "wsdl.path";

    private Log log = null;

    public ServiceUtil()
    {
        log = createLogger();
    }

    protected Log createLogger()
    {
        return ((log != null) ? log : LogFactory.getLog(getClass()));
    }

    protected String getWsdlPath() throws PropertyAccessException
    {
        return PropertyAccessor.getProperty(PROPERTIES_FILE, PROPERTY_KEY_WSDL_PATH);
    }

    protected Service constructService(String wsdlURL, String namespaceURI, String serviceLocalPart) throws MalformedURLException
    {
        return Service.create(new URL(wsdlURL), new QName(namespaceURI, serviceLocalPart));
    }

    public Service createService(String wsdlFile, String namespaceURI, String serviceLocalPart) throws MalformedURLException, PropertyAccessException
    {
        Service service = null;
        log.debug("Begin createService");

        if((wsdlFile == null) || (wsdlFile.length() < 1))
        {
            log.error("WSDL file name is required.");
        }
        else if((namespaceURI == null) || (namespaceURI.length() < 1))
        {
            log.error("Namespace URI is required.");
        }
        else if((serviceLocalPart == null) || (serviceLocalPart.length() < 1))
        {
            log.error("Service local part name is required.");
        }
        else
        {
            final String wsdlPath = getWsdlPath();
            if((wsdlPath != null) && (wsdlPath.length() > 0))
            {
                String wsdlURL = wsdlPath + wsdlFile;
                log.debug("Creating service using the URL: " + wsdlURL);
                service = constructService(wsdlURL, namespaceURI, serviceLocalPart);
            }
            else
            {
                log.error("Unable to retrieve the WSDL path.");
            }
        }

        log.debug("End createService");
        return service;
    }

}
