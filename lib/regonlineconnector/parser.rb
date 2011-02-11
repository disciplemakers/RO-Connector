require 'rexml/document'

class RegonlineConnector
    
  class Parser
     def initialize
     
     end
     
     # Returns hash of event hashes
     def parse_events(response)
       events = elements_to_hash(response, "//Table", "ID")
     end
     
     # Returns hash of registration hashes 
     def parse_registrations(response)
       registration = elements_to_hash(response, "//Registration", "registrationID")
     end
     
     # Returns hash of registration hashes 
     def parse_simple_registrations(response)
       registrations = attributes_to_hash(response, "//registration", "id")
     end

     # Returns hash of registration hashes from a report
     def parse_report(response)
       response_no_escape = response.to_s.gsub!(/_x0020_/,'')
       events = elements_to_hash(response, "//Table1", "ConfirmationNumber")
     end     
     
     private
     
     # Returns hash from xml elements
     def elements_to_hash(xml_response, xpath, hash_id)
       unless xml_response
         return nil
       end
       doc = REXML::Document.new xml_response
       entries = Hash.new
       doc.elements.to_a(xpath).each do |xml_element|
         entry = Hash.new
         
         xml_element.elements.to_a.each do |el|
           if el.text =~ %r{^[0-9]*$} then # Integer value
             entry[el.name] = el.text.to_i
           elsif el.text =~ %r{^[0-9]+\.[0-9]+$} then # Float value
             entry[el.name] = el.text.to_f
           else # String value
             entry[el.name] = el.text
           end
         end
         if entry[hash_id]
           entries[entry[hash_id]] = entry
         end
       end
       entries
     end
     
     # Returns hash from xml attributes
     def attributes_to_hash(xml_response, xpath, hash_id)
       unless xml_response
         return nil
       end
       doc = REXML::Document.new xml_response
       entries = Hash.new
       doc.elements.to_a(xpath).each do |xml_element|
         entry = Hash.new
         xml_element.attributes.each do |name, value|
           if value =~ %r{^[0-9]*$} then # Integer value
             entry[name] = value.to_i
           elsif value =~ %r{^[0-9]+\.[0-9]+$} then # Float value
             entry[name] = value.to_f
           else # String value
             entry[name] = value
           end
         end
         if entry[hash_id]
           entries[entry[hash_id]] = entry
         end
       end
       entries
     end
  end
end