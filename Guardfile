guard 'rake', :task => :html5 do
  watch %r{input/.+\.\w+$}
end

guard 'livereload' do
  watch %r{output/.+\.(html|png)}
end

guard 'webrick', :docroot => 'output' do
end
