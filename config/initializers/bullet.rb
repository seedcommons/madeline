Bullet.enable = true
Bullet.bullet_logger = true
Bullet.unused_eager_loading_enable = false

if Rails.env.development?
  Bullet.alert = false
  Bullet.console = false
  Bullet.add_footer = false
  Bullet.sentry = false
  Bullet.skip_html_injection = false
elsif Rails.env.staging?
  Bullet.console = true
  Bullet.sentry = false
  Bullet.skip_html_injection = true
elsif Rails.env.production?
  Bullet.console = true
  Bullet.sentry = false
  Bullet.skip_html_injection = true
end
