require 'regonlineconnector/client'
require 'regonlineconnector/parser'
require 'regonlineconnector/error'

# Class providing a gateway to other classes that connect to RegOnline.
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
    @parser.parse_events(@client.getEvents.ByAccountID)
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountIDEventID method.
  def event(event_id)
    @parser.parse_events(@client.getEvents.byAccountIDEventID(event_id))
  end
  
  # Returns hashed data from RegOnline's getEvents.byAccountIDWithFilters
  # method. Not yet implemented.
  def filtered_events(filter)
    raise NotImplementedError
  end
  
  # Returns hashed data from RegOnline's geteventfields.RetrieveEventFields2
  # method. Not yet implemented.
  def event_fields(event_id, exclude_amounts=false)
    raise NotImplementedError
  end
  
  # Returns hashed data from RegOnline's retrieveAllRegistrations method.
  def event_registrations(event_id)
    @parser.parse_all_registrations(@client.retrieveAllRegistrations(event_id).RetrieveAllRegistrations)
  end
  
  # Returns hashed data from RegOnline's getEventRegistrations method.
  def simple_event_registrations(event_id)
    @parser.parse_registrations(@client.getEventRegistrations(event_id).RetrieveRegistrationInfo)
  end
    
  # Returns hashed data from RegOnline's retrieveSingleRegistration
  # method. Not yet implemented.
  def registration(event_id, registration_id)
    raise NotImplementedError
  end
  
  # Updates regonline registrations from an XML file using the
  # RegistrationUpdateService.UpdateRegistrations method. Not yet implemented.
  def update_registrations
    raise NotImplementedError
  end
  
  # Returns hashed data from RegOnline's RegOnline.getReport
  # method. Not yet implemented.
  def report(report_id, event_id, start_date, end_date, add_date)
    raise NotImplementedError
  end
  
  #--
  ############################################################################
  #  The following methods are not expected to be implemented at this time.  #
  #  Feel free to implement them as desired and contribute them.  :)         #
  ############################################################################
  #++
  
  # Uses the checkinreg.CheckIn method to check an attendee in.
  # Not implemented. 
  def check_in(registration_id, event_id)
    raise NotImplementedError
  end
  
  # Uses the customfieldresponse.modify method to assign a dna code to an 
  # attendee. Not implemented.
  def assign_dna(registration_id, event_id, custom_field_id, dna_code)
    raise NotImplementedError
  end
  
  # Uses the customfieldresponse.AssignSeat method to assign a seat for an
  # attendee. Not implemented.
  def assign_seat(registration_id, event_id, custom_field_id, level_id,
                  section_id, row_id, seat_id, block_code)
    raise NotImplementedError
  end
  
  # Uses the registrationWS.Modify method to assign a resource group to an 
  # attendee. Not implemented.
  def assign_resource_group(registration_id, resource_group_id)
    raise NotImplementedError
  end
  
  # Uses the registrationWS.assignRoomSharerID method to assign a room sharer
  # to an attendee.  Not implemented.
  def assign_room_sharer(registration_id, room_sharer_id)
    raise NotImplementedError
  end
  
  # Uses the SetCustomFieldResponseStatus.setStatus method to set an attendee's
  # custom field response status. Not implemented.
  def set_custom_field_response_status(registration_id, custom_field_id,
                                       status_id)
    raise NotImplementedError
  end
end