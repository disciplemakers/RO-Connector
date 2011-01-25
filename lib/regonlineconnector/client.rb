require 'regonlineconnector/client/getevents'
require 'regonlineconnector/client/geteventregistrations'
require 'regonlineconnector/client/retrieveallregistrations'
require 'regonlineconnector/client/retrievesingleregistration'
require 'base64'
require 'rubygems'
require 'zip/zip'

class RegonlineConnector
    
  class Client
    def initialize(account_id, username, password)
      @account_id         = account_id
      @username           = username
      @password           = password
    end
    
    def authenticate
      authenticate = RegonlineConnector::Client::GetEvents.new(@account_id,
                                                               @username,
                                                               @password)
      authenticate.Authenticate
    end
    
    def getEvents
      get_events = RegonlineConnector::Client::GetEvents.new(@account_id, 
                                                             @username,
                                                             @password)
    end
    
    def getEventRegistrations(event_id)
      get_event_registrations = 
          RegonlineConnector::Client::GetEventRegistrations.new(event_id,
                                                                @username,
                                                                @password)
    end
    
    def retrieveAllRegistrations(event_id)
      retrieve_all_registrations = 
          RegonlineConnector::Client::RetrieveAllRegistrations.new(event_id,
                                                                   @username,
                                                                   @password)
    end
    
    def retrieveSingleRegistration(event_id, registration_id)
      retrieve_single_registration = 
          RegonlineConnector::Client::RetrieveSingleRegistration.new(event_id,
                                                                     registration_id,
                                                                     @username,
                                                                     @password)
    end
    
    private
    
    def self.zip_to_xml(response, zip_tmp)
        response_decoded = Base64.decode64(response)
        
        File.open(zip_tmp, 'wb') do |f|
          f.puts response_decoded
        end
        
        xml_response = '<?xml version="1.0" encoding="utf-8"?>'
        xml_response << '<string xmlns="http://www.regonline.com/webservices/">'
        Zip::ZipInputStream::open(zip_tmp) do |io|
          io.get_next_entry
          ic = Iconv.new("UTF-8", "UTF-16")
          xml_response << ic.iconv(io.read)
        end
        xml_response << '</string>'
        
        File.delete(zip_tmp)
        
        xml_response
    end
  end
    
end