class Subdomain
  #check if request doesnt match www then return false
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != "www"
  end
end