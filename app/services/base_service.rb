
class BaseService
  attr_accessor :response, :errors

  # Service can call directly
  # ==========================
  def self.call(*, **)
    new(*, **).call
  end
end