require 'soap/wsdlDriver' 

class RegonlineConnector

  class Client  

    # This class provides RegOnline's 
    # getEventFields.asmx[http://www.regonline.com/webservices/geteventFields.asmx]
    # service.
    class GetEventFields

      def initialize(event_id, username, password, exclude_amounts)
        @event_id = event_id
        @username = username
        @password = password
        @exclude_amounts = exclude_amounts
        @wsdl = 'http://www.regonline.com/webservices/getEventFields.asmx?WSDL'
        @field_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end
      
      # Provides access to the RetrieveEventFields2 SOAP operation.
      def RetrieveEventFields2
          response = @field_getter.RetrieveEventFields2(
                                                {"login"    => @username,
                                                 "password" => @password,
                                                 "eventID"  => @event_id,
                                                 "excludeAmounts" => @exclude_amounts})
          response.retrieveEventFields2Result
      end
    end
  end
end