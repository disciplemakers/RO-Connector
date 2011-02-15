require 'soap/wsdlDriver' 

class RegonlineConnector
  
  # The Client class handles communication with RegOnline.
  class Client
  
    # This class provides RegOnline's 
    # getEvents.asmx[https://www.regonline.com/webservices/getEvents.asmx]
    # service.
    class RegistrationUpdateService
      def initialize( account_id, username, password )
        @account_id         = account_id
        @username           = username
        @password           = password
        @wsdl = 'http://www.regonline.com/webservices/RegistrationUpdateService.asmx?WSDL'
        @registration_updater = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end
      
      
    end
  end
end