require 'soap/wsdlDriver'

class RegonlineConnector
  
  class Client
  
    class RetrieveAllRegistrations

      def initialize(event_id, username, password )
        @event_id = event_id
        @username = username
        @password = password
        @wsdl = 'http://www.regonline.com/webservices/RetrieveAllRegistrations.asmx?WSDL'
        @registration_getter = SOAP::WSDLDriverFactory.new(@wsdl).create_rpc_driver
      end

      def RetrieveAllRegistrations
        response = @registration_getter.RetrieveAllRegistrations(
                                              {"customerUserName" => @username,
                                               "customerPassword" => @password,
                                               "eventID"          => @event_id})
                                               
        registrations = RegonlineConnector::Client::zip_to_xml(
            response.retrieveAllRegistrationsResult,
            "/tmp/regonline_connector-#{@username}-#{Time.now.to_i}-retrieveAllRegistrationsResult.zip")
      end
                                             
    end
  
  end
  
end
