class ManningPostprocessor < Asciidoctor::Extensions::Postprocessor
  require 'nokogiri'

  BOOK_XMLNS = 'http://www.manning.com/schemas/book'
  ELEMENTS_MAP = {
    :simpara => :para,
    :literal => :code,
    :phrase => :para,
    :textobject => :caption,
  }

  def process output
    if output.start_with? '<simpara>'
      output = "<preface><title/>#{output}</preface>"
    end

    output.gsub! /<!DOCTYPE.*>/, ''

    @document = Nokogiri::XML output, &:noblanks
    @document.remove_namespaces!

    return output unless @document.root
    @document.root.default_namespace = BOOK_XMLNS
    ELEMENTS_MAP.each {|path, new_name| rename path, new_name }

    remove 'bookinfo/date'
    remove 'bookinfo/authorinitials'
    remove 'mediaobject/caption'
    remove_attribute 'orderedlist', 'numeration'

    nodes('part').each do |part|
      partintro = part.search("./partintro").first
      unless partintro
        partintro = @document.create_element 'partintro'
        part.children.first.next = partintro
      end
      part.search("./para").each do |para|
        para.parent = partintro
      end
    end

    nodes('formalpara/para/screen').each do |screen|
      para = screen.parent
      formalpara = para.parent
      screen.name = 'programlisting'
      screen.parent = formalpara
      formalpara.name = 'example'
      para.remove
    end

    nodes('screen').each do |screen|
      informalexample = @document.create_element 'informalexample'
      screen.previous = informalexample
      screen.name = 'programlisting'
      screen.parent = informalexample
    end

    nodes('calloutlist').each do |calloutlist|
      example = calloutlist.previous
      next unless example.name.end_with? 'example'
      calloutlist.parent = example
    end

    output = @document.to_xml(:encoding => 'UTF-8', :indent => 2)
    output.gsub! ' standalone="no"', ''
    output
  end

  private

  def nodes path
    @document.search "//#{path}"
  end

  def rename path, new_name
    nodes(path).each {|node| node.name = new_name.to_s }
  end

  def remove path
    nodes(path).each &:remove
  end

  def remove_attribute path, attribute
    nodes(path).each {|node| node.remove_attribute attribute }
  end
end
