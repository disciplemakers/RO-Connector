require 'soap/wsdlDriver'

class RegonlineConnector
  
  # The Client class handles communication with RegOnline.
  class Client
  
    # This class provides RegOnline's 
    # RegistrationUpdateService.asmx[https://www.regonline.com/webservices/RegistrationUpdateService.asmx]
    # service.
    class RegistrationUpdateService
      def initialize( username, password )
        @username           = username
        @password           = password
      end
      
      def UpdateRegistrations(request_xml)
        envelope = SOAP::SOAPEnvelope.new(soap_header, body)
        request_string = SOAP::Processor.marshal(envelope)
        request = SOAP::StreamHandler::ConnectionData.new(request_xml)
        stream = SOAP::HTTPStreamHandler.new(SOAP::Property.new)
        resp_data = stream.send('http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                                request,
                                "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
                               )
      end
      
      def generate_request_xml(event_id, update_data_hash)
        envelope = SOAP::SOAPEnvelope.new(UpdateRegistrationsRequestHeader,
                                          UpdateRegistrationsRequest(event_id, update_data_hash))
        request_string = SOAP::Processor.marshal(envelope)
      end
      
      private
      
      def UpdateRegistrationsRequestHeader
        header = SOAP::SOAPHeader.new
        request_header = SOAP::SOAPElement.new('updateRegistrationsRequestHeader', '')
        request_header.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateService'
        request_header.add(SOAP::SOAPElement.new('login', @username))
        request_header.add(SOAP::SOAPElement.new('password', @password))
        header.add(nil, request_header)
        header
      end
      
      def UpdateRegistrationsRequest(event_id, update_data_hash)
        body_item = SOAP::SOAPElement.new('UpdateRegistrationsRequest', nil)
        body_item.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateService'
        event_id = SOAP::SOAPElement.new('eventID', '864100')
        event_id.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes'
        body_item.add(event_id)
        registrations = SOAP::SOAPElement.new('registrations', nil)
        registrations.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes'
        
        update_data_hash.each do |registration_id, registration_data|
          registration = SOAP::SOAPElement.new('registration', nil)
          registration.add(SOAP::SOAPElement.new('registrationId', registration_id))
          
          custom_fields = SOAP::SOAPElement.new('customFields', nil)
          registration_data['customFields'].each do |field_name, field_value|
            custom_field = SOAP::SOAPElement.new('customField', nil)
            custom_field.add(SOAP::SOAPElement.new('fieldName', field_name))
            custom_field.add(SOAP::SOAPElement.new('value', field_value))
            custom_field.add(SOAP::SOAPElement.new('quantity', '1'))
            custom_fields.add(custom_field)
          end
          registration.add(custom_fields)
          registrations.add(registration)
        end

        body_item.add(registrations)
        body = SOAP::SOAPBody.new(body_item)        
      end
    end
  end
end

