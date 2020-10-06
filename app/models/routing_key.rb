class RoutingKey < ApplicationRecord
  validate :valid_routing_key

  def valid_routing_key
    unless routing_key.match(/^R[\w]{31}/) or routing_key.match(/[a-fA-F0-9]{32}/)
      errors.add(:routing_key, 'is not valid')
    end
  end
end
