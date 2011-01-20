class RegonlineConnector
  
  # Custom error class for rescuing from all RegonlineConnector errors    
  class Error < StandardError; end
  
  # Raised when Regonline reports invalid credentials
  class AuthenticationError < Error; end
  
end