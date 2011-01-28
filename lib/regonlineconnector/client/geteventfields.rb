require 'soap/wsdlDriver' 

class RegonlineConnector

  class Client  

    class GetEventFields

      def initialize(event_id, username, password, exclude_amounts = "false" )
        @event_id = event_id
        @username = username
        @password = password
        @exclude_amounts = exclude_amounts
        @wsdl = 'http://www.regonline.com/webservices/getEventFields.asmx?WSDL'
        @field_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end

      def RetrieveEventFields2
        begin
          response = @field_getter.RetrieveEventFields2(
                                                {"login"    => @username,
                                                 "password" => @password,
                                                 "eventID"  => @event_id,
                                                 "excludeAmounts" => @exclude_amounts})
          response.retrieveEventFields2Result
        rescue SOAP::FaultError => exception
          if exception.to_s.include?("Authentication failure")
            raise RegonlineConnector::AuthenticationError
          else
            raise RegonlineConnector::RegonlineServerError
          end
        end
      end
      
    end
  
  end
  
end
