class RegonlineConnector
  
  # Custom error class for rescuing from all RegonlineConnector errors    
  class Error < StandardError; end
  
  # Raised when Regonline reports invalid credentials
  class AuthenticationError < Error; end
  
  # Raised when Regonline server raises other SOAP fault error
  class RegonlineServerError < Error; end
  
end