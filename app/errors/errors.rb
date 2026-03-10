module MiscellaneousErrors
  class InvalidAmountSubmitted < StandardError; end
  class ProductOutOfStock < StandardError; end
  class NotEnoughChange < StandardError; end
end
