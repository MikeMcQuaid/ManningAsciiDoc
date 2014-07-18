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
    return output if output.start_with? '<!DOCTYPE html>'

    if output.start_with? '<simpara'
      output = "<preface><title/>#{output}</preface>"
    end
    output.gsub! /<!DOCTYPE.*>/, ''

    @document = Nokogiri::XML output, &:noblanks
    @document.remove_namespaces!

    root = @document.root
    return output unless root

    root.name = 'chapter' if root.name == 'preface' or root.name == 'appendix'
    root.default_namespace = BOOK_XMLNS

    ELEMENTS_MAP.each {|path, new_name| rename path, new_name }

    remove 'bookinfo/date'
    remove 'bookinfo/authorinitials'
    remove 'mediaobject/caption'
    remove_attributes 'orderedlist', 'numeration'
    remove_attributes 'screen', 'linenumbering'
    remove_attributes 'programlisting', 'linenumbering'
    remove_attributes 'table', 'frame', 'rowsep', 'colsep'
    remove_attributes 'entry', 'align', 'valign'

    nodes('part').each do |part|
      partintro = part.search("./partintro").first
      unless partintro
        partintro = @document.create_element 'partintro'
        part.children.first.next = partintro
      end
      intro = part.search("./para") + part.search("./itemizedlist")
      intro.each do |para|
        para.parent = partintro
      end
    end

    nodes('programlisting//@language').each do |language|
      language.name = 'format'
    end

    formal_screens = nodes('formalpara/para/screen') +
                     nodes('formalpara/para/programlisting')
    formal_screens.each do |screen|
      para = screen.parent
      formalpara = para.parent
      screen.name = 'programlisting'
      screen.parent = formalpara
      formalpara.name = 'example'
      setup_long_annotations formalpara
      para.remove
    end

    screens = nodes('screen') + nodes('programlisting')
    screens.each do |screen|
      informalexample = @document.create_element 'informalexample'
      setup_long_annotations informalexample
      screen.previous = informalexample
      screen.name = 'programlisting'
      screen.parent = informalexample
    end

    nodes('appendix').each do |appendix|
      part = appendix.parent
      next unless part.name == 'part'
      appendix.parent = part.parent
    end

    nodes('calloutlist').each do |calloutlist|
      example = calloutlist.previous
      next unless example.name.end_with? 'example'
      calloutlist.parent = example
    end

    nodes('thead/row/entry').each do |entry|
      new_entry = @document.create_element 'entry'
      entry.previous = new_entry
      entry.name = 'para'
      entry.parent = new_entry
    end

    nodes('attribution').each do |attribution|
      citetitle = attribution.element_children.first

      attribution_sections = []
      attribution.children.each do |child|
        child_text = child.text.strip
        next if child_text.empty?
        attribution_sections << child.text.strip
      end

      attribution.content = attribution_sections.join ', '
    end

    nodes('blockquote').each do |blockquote|
      next if blockquote.parent.name == 'para'
      para = @document.create_element 'para'
      blockquote.previous = para
      blockquote.parent = para
    end

    nodes('xref').each do |xref|
      id = xref.attributes['linkend']
      target = @document.search("*[@id='#{id}']").first
      target_type = target.name if target

      target_type = case target_type
      when 'example' then 'Listing'
      when nil then 'Section'
      else target_type.capitalize
      end

      xref.previous = "#{target_type} "
    end

    nodes('colspec').each {|colspec| colspec.remove }

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

  def remove_attributes path, *attributes
    nodes(path).each do |node|
      attributes.each do |attribute|
        node.remove_attribute attribute
      end
    end
  end

  def setup_long_annotations node
    return unless node['role'].to_s.split.include? 'long-annotations'
    node['annotations'] = 'below'
    node.remove_attribute 'role'
  end
end
