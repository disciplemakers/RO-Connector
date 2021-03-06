require 'soap/wsdlDriver' 

class RegonlineConnector
  
  # The Client class handles communication with RegOnline.
  class Client
  
    # This class provides RegOnline's 
    # getEvents.asmx[https://www.regonline.com/webservices/getEvents.asmx]
    # service.
    class GetEvents
      def initialize( account_id, username, password )
        @account_id         = account_id
        @username           = username
        @password           = password
        @wsdl = 'http://www.regonline.com/webservices/getEvents.asmx?WSDL'
        @event_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end

      # Test whether valid authentication credentials have been provided (by
      # attempting to get a list of events).
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
    
      def ByAccountIDWithFilters(filter_xml, filter_operator, filter_like_matching)
        response = @event_getter.ByAccountIDWithFilters({"AccountID"      => @account_id,
                                                         "Username"       => @username,
                                                         "Password"       => @password,
                                                         "xmlFilterData"  => filter_xml,
                                                         "FilterOperator" => filter_operator,
                                                         "LikeMatching"   => filter_like_matching})                                                    
        response.byAccountIDWithFiltersResult
      end                                   
    end
  end
end  