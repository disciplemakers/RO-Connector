require 'soap/wsdlDriver' 

class RegonlineConnector
  
  class Client
  
    class GetEvents
      def initialize( account_id, username, password )
        @account_id         = account_id
        @username           = username
        @password           = password
        @wsdl = 'http://www.regonline.com/webservices/getEvents.asmx?WSDL'
        @event_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end

      def Authenticate
        response = @event_getter.ByAccountID({"AccountID" => @account_id,
                                               "Username"  => @username,
                                               "Password"  => @password})
        if response.byAccountIDResult == 'The credentials you supplied are not valid.'
          return false
        else
          return true
        end
      end

      def ByAccountID
        response = @event_getter.ByAccountID({"AccountID" => @account_id,
                                               "Username"  => @username,
                                               "Password"  => @password})
        response.byAccountIDResult
      end
    
      def ByAccountIDEventID(event_id)
        response = @event_getter.ByAccountIDEventID({"AccountID" => @account_id,
                                                      "Username"  => @username,
                                                      "Password"  => @password,
                                                      "EventId"   => event_id})
        response.byAccountIDEventIDResult
      end
    
      def byAccountIDWithFilters
        # Insert code here ;)      
      end
                                          
    end
  
  end

end  