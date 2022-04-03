require 'webrick'
require 'tofu'
require_relative 'src/app'

port = Integer(ENV['PORT']) rescue 8000
server = WEBrick::HTTPServer.new({
  :Port => port,
  :FancyIndexing => false
})

tofu = Tofu::Bartender.new(Signage::Session, 'signage')
server.mount('/app', Tofu::Tofulet, tofu)

server.mount_proc('/') {|req, res|
  res['Pragma'] = 'no-store'
  res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, '/app/signage.html')
}

trap(:INT){exit!}
Thread.start do
  while $stdin.gets
    Tofu::reload_erb
  end
end
server.start
