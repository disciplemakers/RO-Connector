require 'regonlineconnector/client/geteventfields'
require 'regonlineconnector/client/geteventregistrations'
require 'regonlineconnector/client/getevents'
require 'regonlineconnector/client/registrationupdateservice'
require 'regonlineconnector/client/regonline'
require 'regonlineconnector/client/retrieveallregistrations'
require 'regonlineconnector/client/retrievesingleregistration'
require 'base64'
require 'md5'
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
    
    def getEventFields(event_id, exclude_amounts = "false")
      get_event_fields = 
          RegonlineConnector::Client::GetEventFields.new(event_id,
                                                         @username,
                                                         @password,
                                                         exclude_amounts)
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
    
    def regOnline(report_id, event_id, start_date, end_date, add_date)
      report_registrations = 
          RegonlineConnector::Client::RegOnline.new(@account_id, @username, @password,
                                                    report_id, event_id, start_date,
                                                    end_date, add_date)
    end
    
    private
    
    def self.zip_to_xml(response)
        response_decoded = Base64.decode64(response)
        zip_tmp = '/tmp/' + MD5.md5(rand(1234567).to_s).to_s
        
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