guard 'rake', :task => :html5 do
  watch %r{input/.+\.\w+$}
end

guard 'livereload' do
  watch %r{output/.+\.(html|png)}
end

guard 'process', :name => 'webrick', :command => 'ruby -run -e httpd output/ -p 3000' do
end
