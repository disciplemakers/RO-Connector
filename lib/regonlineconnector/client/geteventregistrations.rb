require 'soap/wsdlDriver' 

class RegonlineConnector
  
  class Client
  
    # This class provides RegOnline's 
    # getEventRegistrations.asmx[http://www.regonline.com/webservices/geteventregistrations.asmx]
    # service.
    class GetEventRegistrations

      def initialize(event_id, username, password )
        @event_id = event_id
        @username = username
        @password = password
        @wsdl = 'http://www.regonline.com/webservices/getEventRegistrations.asmx?WSDL'
        @registrant_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end

      def RetrieveRegistrationInfo
        response = @registrant_getter.RetrieveRegistrationInfo(
                                              {"login"    => @username,
                                               "password" => @password,
                                               "eventID"  => @event_id})
        response.retrieveRegistrationInfoResult
      end                                      
    end
  end
end
