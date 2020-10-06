require 'rufus-scheduler'

s = Rufus::Scheduler.singleton

return if defined?(Rails::Console) || Rails.env.test? || File.split($0).last == 'rake'

s.every '1m' do
  RoutingKey.where(verified: false).where("created_at < ?", 10.minutes.ago).each do |r|
    Rails.logger.info "Deleting pending verification #{r.routing_key} because it's more than ten minutes old"
    r.destroy
  end
  RoutingKey.where(verified: true).where.not(token: [nil, ""]).where("created_at < ?", 10.minutes.ago).each do |r|
    Rails.logger.info "Deleting pending unverification #{r.routing_key} because it's more than ten minutes old"
    r.destroy
  end
end