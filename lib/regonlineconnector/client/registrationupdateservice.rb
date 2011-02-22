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
        request = SOAP::StreamHandler::ConnectionData.new(request_xml)
        stream = SOAP::HTTPStreamHandler.new(SOAP::Property.new)
        resp_data = stream.send('http://www.regonline.com/webservices/RegistrationUpdateService.asmx',
                                request,
                                "http://www.regonline.com/webservices/2007/08/RegistrationUpdateService/UpdateRegistrations"
                               )
      end
      
      def generate_request_xml(event_id, update_data_hash)
        envelope = SOAP::SOAPEnvelope.new(update_registrations_request_header,
                                          update_registrations_request(event_id, update_data_hash))
        request_string = SOAP::Processor.marshal(envelope)
      end
      
      private
      
      def update_registrations_request_header
        header = SOAP::SOAPHeader.new
        request_header = SOAP::SOAPElement.new('updateRegistrationsRequestHeader', '')
        request_header.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateService'
        request_header.add(SOAP::SOAPElement.new('login', @username))
        request_header.add(SOAP::SOAPElement.new('password', @password))
        header.add(nil, request_header)
        header
      end
      
      def update_registrations_request(event_id, update_data_hash)
        body_item = SOAP::SOAPElement.new('UpdateRegistrationsRequest', nil)
        body_item.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateService'
        event_id_xml = SOAP::SOAPElement.new('eventID', event_id.to_s)
        event_id_xml.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes'
        body_item.add(event_id_xml)
        registrations = SOAP::SOAPElement.new('registrations', nil)
        registrations.extraattr['xmlns'] = 'http://www.regonline.com/webservices/2007/08/RegistrationUpdateServiceTypes'
        
        update_data_hash.each do |registration_id, registration_data|
          registration = SOAP::SOAPElement.new('registration', nil)
          registration.add(SOAP::SOAPElement.new('registrationId', registration_id.to_s))
          
          custom_fields = SOAP::SOAPElement.new('customFields', nil)
          registration_data['custom_fields'].each do |field_name, field_value|
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

