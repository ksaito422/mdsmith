if ARGV.empty?
  puts "Usage: ruby mdsmith.rb <markdown_file>"
  exit 1
end

f = ARGV[0]

unless File.exist?(f)
  puts "File not found: #{f}"
  exit 1
end
