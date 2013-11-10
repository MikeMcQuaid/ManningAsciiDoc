require 'rubygems'
require 'rake'
require 'rake/clean'
require 'asciidoctor'
require 'asciidoctor/extensions'
require './asciidoctor_extensions/manning_postprocessor'

Asciidoctor::Extensions.register do
  postprocessor ManningPostprocessor
end

INPUT_DIRECTORY = "input"
OUTPUT_DIRECTORY = "output"
INPUT_PATH = "#{FileUtils.pwd}/#{INPUT_DIRECTORY}"
OUTPUT_PATH = "#{FileUtils.pwd}/#{OUTPUT_DIRECTORY}"
TEMPLATES_PATH = "#{FileUtils.pwd}/templates"

BOOK_HTML5 = "#{OUTPUT_PATH}/book.html"
BOOK_DOCBOOK = "#{OUTPUT_PATH}/book.xml"
BOOK_PDF = "#{OUTPUT_PATH}/book.pdf"

BOOK_XSD = "#{OUTPUT_PATH}/manning-book.xsd"
BOOK_XSLT = "#{FileUtils.pwd}/docbook-to-manning-book.xslt"

BOOK_SCHEMA = 'https://author.manning.com/resources/schemas/manning-book.xsd'

BOOK_TITLE = "#{INPUT_PATH}/Title.adoc"
BOOK_PATHS = FileList["#{INPUT_PATH}/*.*"].exclude(BOOK_TITLE)
BOOK_FILES = BOOK_PATHS.sub("#{INPUT_PATH}/", '')
BOOK_XML_PATHS = BOOK_PATHS.sub(INPUT_PATH, OUTPUT_PATH).ext('.xml')
BOOK_XML_FILES = BOOK_XML_PATHS.sub("#{OUTPUT_PATH}/", '')
BOOK_IMAGES = FileList["#{INPUT_PATH}/**/*.png"]
BOOK_OUTPUT_IMAGES = BOOK_IMAGES.sub(INPUT_PATH, OUTPUT_PATH)

task :default => :html5
task :all     => [:html5, :pdf]
task :html5   => BOOK_HTML5
task :docbook => BOOK_DOCBOOK
task :pdf     => BOOK_PDF
task :html    => :html5
task :xml     => :docbook

task :http => BOOK_HTML5 do
  require 'webrick'

  server = WEBrick::HTTPServer.new \
    :BindAddress => "localhost",
    :Port => 8080,
    :DocumentRoot => OUTPUT_PATH

  trap "INT" do
    server.shutdown
  end

  server.start
end

def validate file
  document = Nokogiri::XML IO.read file
  xsd = Nokogiri::XML::Schema IO.read BOOK_XSD
  errors = xsd.validate document
  errors.each {|error| puts "#{file}:#{error.line}\n#{error}\n" }
  raise 'XML schema validation failed!' if errors.any?
end

def asciidoctor backend, output_file, *files
  puts "asciidoctor: generating #{output_file}"
  input = ""
  files.flatten.each {|file| input << IO.read(file) << "\n\n" }
  options = {
    :attributes => {
      'backend' => backend.to_s,
      'doctype' => 'book',
    },
    :header_footer => files.length > 1,
    :to_file => output_file,
    :safe => Asciidoctor::SafeMode::UNSAFE,
  }
  Asciidoctor.render input, options
end

file BOOK_HTML5 => [OUTPUT_DIRECTORY, BOOK_TITLE,
                    *BOOK_PATHS, *BOOK_OUTPUT_IMAGES] do
  FileUtils.cd INPUT_PATH do
    asciidoctor :html5, BOOK_HTML5, BOOK_TITLE, BOOK_FILES
  end
  FileUtils.ln_sf BOOK_HTML5, "#{OUTPUT_PATH}/index.html"
end

file BOOK_PDF => BOOK_DOCBOOK do
  sh 'AAMakePDF/createPDF.sh', BOOK_DOCBOOK, BOOK_PDF, 'AAMakePDF/'
  FileUtils.rm "#{OUTPUT_DIRECTORY}/book.xml.temp.xml"
  FileUtils.rm 'c:\sw\text.txt'
  FileUtils.rm 'AAMakePDF/temp.xml'
  FileUtils.ln_sf BOOK_PDF, "book.pdf"
end

file BOOK_DOCBOOK => [BOOK_TITLE, *BOOK_XML_PATHS, *BOOK_OUTPUT_IMAGES] do
  FileUtils.cd INPUT_PATH do
    asciidoctor :docbook45, BOOK_DOCBOOK, BOOK_TITLE, BOOK_FILES
    validate BOOK_DOCBOOK
  end
end

input_files_for_xml = proc do |xml_filename|
  basename = File.basename(xml_filename, '.xml')
  FileList["#{INPUT_DIRECTORY}/#{basename}.*"].first
end

rule '.xml' => [input_files_for_xml, BOOK_XSD] do |input|
  xml = input.name
  asciidoctor :docbook45, xml, input.source
  validate xml
end

rule /#{OUTPUT_DIRECTORY}\/.+\.png/ \
     => proc {|f| f.sub(OUTPUT_PATH, INPUT_PATH) } do |input|
  output_image = input.name
  FileUtils.mkdir_p File.dirname(output_image)
  FileUtils.cp input.source, output_image
end

file BOOK_XSD => OUTPUT_DIRECTORY do
  sh 'curl', BOOK_SCHEMA, '--output', BOOK_XSD
end

directory OUTPUT_DIRECTORY

CLEAN.include FileList["#{OUTPUT_DIRECTORY}/{*.html,*.xml,book.pdf,*/}",
                       "book.*"]
