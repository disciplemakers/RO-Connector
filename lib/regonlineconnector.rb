require 'regonlineconnector/client'
require 'regonlineconnector/parser'
require 'regonlineconnector/error'

# = regonlineconnector.rb - Regonline API Interface Library
# 
# Copyright (c) 2011 Adam Focht and Brian Roberg
#
# RegonlineConnector provides a ruby interface to the RegOnline Web
# API[http://forums.regonline.com/forums/thread/1383.aspx].
#
# This class provides ruby-friendly method names that return 
# parsed RegOnline provided via hashes of hashes.
#
# == Example
#
# === Authentication
#
#  require 'regonlineconnector'
#  
#  roc = RegonlineConnector.new(123456, 'joeuser', 'password')
#  
#  if !roc.authenticate
#    puts "Invalid Credentials"
#  end
#
# === Getting All Events
# 
#  require 'regonlineconnector'
#  require 'pp'
#  
#  roc = RegonlineConnector.new(123456, 'joeuser', 'password')
#  
#  events = roc.events(654321)
#  pp events
#
class RegonlineConnector
  def initialize(account_id, username, password)
    @client  = RegonlineConnector::Client.new(account_id, username, password)
    @parser  = RegonlineConnector::Parser.new
  end
  
  # Returns boolean indicating whether valid login credentials have
  # been supplied.
  def authenticate
    @authenticate = @client.authenticate
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountID method.
  def events
    events = @client.getEvents.ByAccountID
    if events.include?("The credentials you supplied are not valid.")
          raise RegonlineConnector::AuthenticationError
    end
    @parser.parse_events(events)
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountIDEventID method.
  def event(event_id)
    event = @client.getEvents.ByAccountIDEventID(event_id)
    if event.include?('The credentials you supplied are not valid.')
          raise RegonlineConnector::AuthenticationError
    end
    @parser.parse_events(event)
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountIDWithFilters
  # method.
  def filtered_events(filter_hash, filter_operator, filter_like_matching)
    unless filter_like_matching == 'true' || filter_like_matching == 'false'
      raise ArgumentError, "filter_like_matching argument must be either 'true' or 'false'"
    end 
    unless filter_operator == 'and' || filter_operator == 'or'
      raise ArgumentError, "filter_operator argument must be either 'and' or 'or'"
    end
    unless filter_hash.instance_of?(Hash)
      raise ArgumentError, "filter hash must be hash"
    end
    if filter_hash.empty?
      raise ArgumentError, "filter hash must not be empty"
    end
    
    filter_xml = "<filters>"
    filter_hash.sort.each {|filter, value| filter_xml << "<#{filter}>#{value}</#{filter}>"}
    filter_xml << "</filters>"

    begin
      events = @client.getEvents.ByAccountIDWithFilters(filter_xml, filter_operator, filter_like_matching)
    rescue SOAP::FaultError
      raise   RegonlineConnector::RegonlineServerError
    end

    if events.include?('The credentials you supplied are not valid.')
          raise RegonlineConnector::AuthenticationError
    end
    @parser.parse_events(events)
  end
  
  # Returns hashed data from RegOnline's geteventfields.RetrieveEventFields2
  # method.
  def event_fields(event_id, exclude_amounts="false")
    begin
      @parser.parse_events(@client.getEventFields(event_id, exclude_amounts).RetrieveEventFields2)
    rescue SOAP::FaultError => exception
      if exception.to_s.include?("Authentication failure")
        raise RegonlineConnector::AuthenticationError
      else
        raise RegonlineConnector::RegonlineServerError
      end
    end
  end
  
  # Returns hashed data from RegOnline's getEventRegistrations method.
  def simple_event_registrations(event_id)
    begin
      @parser.parse_registrations(@client.getEventRegistrations(event_id).RetrieveRegistrationInfo)
    rescue SOAP::FaultError => exception
      if exception.to_s.include?("Authentication failure")
        raise RegonlineConnector::AuthenticationError
      else
        raise RegonlineConnector::RegonlineServerError
      end
    end
  end
  
  # Returns hashed data from RegOnline's retrieveAllRegistrations method.
  def event_registrations(event_id)
    begin
      @parser.parse_registrations(@client.retrieveAllRegistrations(event_id).RetrieveAllRegistrations)
    rescue SOAP::FaultError => exception
      if exception.to_s.include?("Authentication failure")
        raise RegonlineConnector::AuthenticationError
      else
        raise RegonlineConnector::RegonlineServerError
      end
    end
  end
    
  # Returns hashed data from RegOnline's retrieveSingleRegistration
  # method.
  def registration(event_id, registration_id)
    begin
      @parser.parse_registrations(@client.retrieveSingleRegistration(event_id, registration_id).RetrieveSingleRegistration)
    rescue SOAP::FaultError => exception
      if exception.to_s.include?("Authentication failure")
        raise RegonlineConnector::AuthenticationError
      else
        raise RegonlineConnector::RegonlineServerError
      end
    end
  end
  
  # Returns hashed data from RegOnline's RegOnline.getReport
  # method.
  def report(report_id, event_id, start_date, end_date, add_date)
    unless add_date == 'true' || add_date == 'false'
      raise ArgumentError, "add_date argument must be either 'true' or 'false'"
    end
    start_t = Date.parse(start_date)
    end_t = Date.parse(end_date)
    unless start_t < DateTime.now
      raise ArgumentError, "start_time argument cannot be in future"
    end
    unless end_t < DateTime.now
      raise ArgumentError, "end_time argument cannot be in future"
    end
    unless start_t < end_t
      raise ArgumentError, "start time must be before end time cannot be in future"
    end
    
    registrations = @client.regOnline(report_id, event_id, start_date, end_date, add_date).getReport
    if registrations.include?("Error 4458") && @client.authenticate == false
      raise RegonlineConnector::AuthenticationError
    end
    @parser.parse_report(registrations)
  end
  
  # Updates regonline registrations from an XML file using the
  # RegistrationUpdateService.UpdateRegistrations method. <b><em>Not yet implemented.</em></b>
  def update_registrations
    raise NotImplementedError
  end
  
  
  #--
  ############################################################################
  #  The following methods are not expected to be implemented at this time.  #
  #  Feel free to implement them as desired and contribute them.  :)         #
  ############################################################################
  #++
  
  # Uses the checkinreg.CheckIn method to check an attendee in.
  # <b><em>Not implemented.</em></b> 
  def check_in(registration_id, event_id)
    raise NotImplementedError
  end
  
  # Uses the customfieldresponse.modify method to assign a dna code to an 
  # attendee. <b><em>Not implemented.</em></b>
  def assign_dna(registration_id, event_id, custom_field_id, dna_code)
    raise NotImplementedError
  end
  
  # Uses the customfieldresponse.AssignSeat method to assign a seat for an
  # attendee. <b><em>Not implemented.</em></b>
  def assign_seat(registration_id, event_id, custom_field_id, level_id,
                  section_id, row_id, seat_id, block_code)
    raise NotImplementedError
  end
  
  # Uses the registrationWS.Modify method to assign a resource group to an 
  # attendee. <b><em>Not implemented.</em></b>
  def assign_resource_group(registration_id, resource_group_id)
    raise NotImplementedError
  end
  
  # Uses the registrationWS.assignRoomSharerID method to assign a room sharer
  # to an attendee.  <b><em>Not implemented.</em></b>
  def assign_room_sharer(registration_id, room_sharer_id)
    raise NotImplementedError
  end
  
  # Uses the SetCustomFieldResponseStatus.setStatus method to set an attendee's
  # custom field response status. <b><em>Not implemented.</em></b>
  def set_custom_field_response_status(registration_id, custom_field_id,
                                       status_id)
    raise NotImplementedError
  end
end