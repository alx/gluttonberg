Merb.logger.info("Loaded DEVELOPMENT Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = true
  c[:reload_time] = 0.5
  c[:log_auto_flush ] = true
}

dependency 'dm-sweatshop'

Merb::BootLoader.after_app_loads do
  # Load observers last
  Merb.push_path(:observers, Merb.root / "app/observers")
end