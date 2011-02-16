require 'soap/wsdlDriver' 

class RegonlineConnector
  
  # The Client class handles communication with RegOnline.
  class Client
  
    # This class provides RegOnline's 
    # RegistrationUpdateService.asmx[https://www.regonline.com/webservices/RegistrationUpdateService.asmx]
    # service.
    class RegistrationUpdateService
      def initialize( account_id, username, password )
        @account_id         = account_id
        @username           = username
        @password           = password
        @wsdl = 'http://www.regonline.com/webservices/RegistrationUpdateService.asmx?WSDL'
        @registration_updater = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end
      
      def UpdateRegistrations(updates)
        response = @registration_updater.UpdateRegistrations(
                                              {"AccountID" => @account_id,
                                               "Username"  => @username,
                                               "Password"  => @password})
        #response.byAccountIDResult
      end
    end
  end
end