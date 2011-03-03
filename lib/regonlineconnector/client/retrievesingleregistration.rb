require 'soap/wsdlDriver'

class RegonlineConnector
  
  class Client
  
    # This class provides RegOnline's 
    # RetrieveSingleRegistration.asmx[http://www.regonline.com/webservices/RetrieveSingleRegistration.asmx]
    # service.
    class RetrieveSingleRegistration

      def initialize(event_id, registration_id, username, password)
        @event_id = event_id
        @registration_id = registration_id
        @username = username
        @password = password
        @wsdl = 'http://www.regonline.com/webservices/RetrieveSingleRegistration.asmx?WSDL'
        @registration_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end
      
      # Provides access to the RetrieveSingleRegistration SOAP operation.
      def RetrieveSingleRegistration
        response = @registration_getter.RetrieveSingleRegistration(
                                              {"customerUserName" => @username,
                                               "customerPassword" => @password,
                                               "eventID"          => @event_id,
                                               "registrationID"   => @registration_id})
                                               
        registration = RegonlineConnector::Client::zip_to_xml(
            response.retrieveSingleRegistrationResult)
      end                                      
    end
  end
end