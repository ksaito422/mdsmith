require_relative 'lib/mdsmith/token'
require_relative 'lib/mdsmith/lexer'
require_relative 'lib/mdsmith/node'
require_relative 'lib/mdsmith/parser'
require_relative 'lib/mdsmith/generator'

if ARGV.empty?
  puts "Usage: ruby mdsmith.rb <markdown_file> [-o <output_file>]"
  exit 1
end

output_file = nil
if (i = ARGV.index("-o"))
  output_file = ARGV[i + 1]
  ARGV.delete_at(i + 1)
  ARGV.delete_at(i)
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

if output_file
  File.write(output_file, html)
else
  puts html
end
