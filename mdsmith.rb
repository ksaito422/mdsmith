require_relative 'lib/mdsmith/token'
require_relative 'lib/mdsmith/lexer'
require_relative 'lib/mdsmith/node'
require_relative 'lib/mdsmith/parser'
require_relative 'lib/mdsmith/generator'

if ARGV.empty?
  puts "Usage: ruby mdsmith.rb <markdown_file>"
  exit 1
end

f = ARGV[0]

unless File.exist?(f)
  puts "File not found: #{f}"
  exit 1
end

markdown_text = File.read(f)

lexer = Mdsmith::Lexer.new(markdown_text)
tokens = lexer.tokenize

parser = Mdsmith::Parser.new(tokens)
ast = parser.parse

generator = Mdsmith::Generator.new(ast)
html = generator.generate

puts html
