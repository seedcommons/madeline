# Enable Hirb in pry console
require 'hirb'
Pry.config.print = proc do |output, value, _pry_|
    Hirb::View.view_or_page_output(value) || Pry::DEFAULT_PRINT.call(output, value, _pry_)
end

def pbcopy(arg)
  out = arg.is_a?(String) ? arg : arg.inspect
  IO.popen('pbcopy', 'w') { |io| io.puts out }
  puts out
  true
end
