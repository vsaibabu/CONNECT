/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package gov.hhs.fha.nhinc.admindist.adapter;
import javax.jws.WebService;
import javax.xml.ws.BindingType;
import gov.hhs.fha.nhinc.admindistribution.adapter.AdapterAdminDistOrchImpl;
import gov.hhs.fha.nhinc.common.nhinccommon.AssertionType;
import javax.annotation.Resource;
import javax.xml.ws.WebServiceContext;
import gov.hhs.fha.nhinc.saml.extraction.SamlTokenExtractor;

/**
 *
 * @author dunnek
 */
@WebService(serviceName = "Adapter_AdministrativeDistributionSecured", portName = "Adapter_AdministrativeDistributionSecured_PortType", endpointInterface = "gov.hhs.fha.nhinc.adapteradmindistribution.AdapterAdministrativeDistributionSecuredPortType", targetNamespace = "urn:gov:hhs:fha:nhinc:adapteradmindistribution", wsdlLocation = "WEB-INF/wsdl/AdapterAdministrativeDistributionSecured/AdapterAdminDistSecured.wsdl")
@BindingType(value = javax.xml.ws.soap.SOAPBinding.SOAP12HTTP_BINDING)
public class AdapterAdministrativeDistributionSecured {
        @Resource
    private WebServiceContext context;

    protected AssertionType extractAssertion(WebServiceContext context)
    {
        return SamlTokenExtractor.GetAssertion(context);
    }

    public void sendAlertMessage(gov.hhs.fha.nhinc.common.nhinccommonadapter.RespondingGatewaySendAlertMessageSecuredType body) {

        AssertionType assertion = extractAssertion(context);
        getImpl().sendAlertMessage(body.getEDXLDistribution(),assertion);

    }
    protected AdapterAdminDistOrchImpl getImpl()
    {
        return new AdapterAdminDistOrchImpl();
    }

}
