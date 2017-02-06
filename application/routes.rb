# encoding: utf-8
################################################################################
## Initial developer: Massimo Maria Ghisalberti <massimo.ghisalberti@gmail.org>
## Date: 2016-12-18
## Company: Pragmas <contact.info@pragmas.org>
## Licence: Apache License Version 2.0, http://www.apache.org/licenses/
################################################################################

class MainApplication < Sinatra::Base
  
  before do
    
    absolute_path = File.join(settings.views, request.path)
    rev_root = File.dirname(absolute_path)
    index = settings.metadatas.fetch2(['application','home','document'], 'index').to_sym  
    
    documents =
      if File.directory?(absolute_path)
        @request_root = request.path
        [File.join(absolute_path, "#{index}.markdown")]
      else
        @request_root = File.dirname(request.path)
        Dir[File.join(rev_root, '*.markdown')].reduce([]) { |acc, d|
          #acc << d unless d.match(File.basename(request.path)).nil?
          acc << d unless d.gsub(DOC_FOLDER, '').match(File.basename(request.path)).nil?
          acc
        }
      end

    @request_path, @request_meta =
      if documents.empty?
        ['/', File.join(settings.views, "#{index}.yml")]
      else
        req_path = documents.first.gsub(settings.views, '')[1..-1].gsub(/\.\w*$/, '')
        [req_path, File.join(settings.views, "#{req_path}.yml")]
      end
    @metadatas = settings.metadatas.merge( File.exist?(@request_meta) ? YAML.load_file(@request_meta).to_h : {})

    unless @metadatas.fetch2(['document','load'], nil).nil?
      File.open(File.join(ROOT_FOLDER, @metadatas['document']['load']), 'r') { |f| @document_source = f.read }
    end
  end  


  get '/' do
    document = settings.metadatas.fetch2(['application','home','document'], 'index').to_sym 
    slim(:'layouts/main' , :locals => { :content => markdown(document), :metadatas => @metadatas})
  end

  get '/stylesheets/documents.css' do
    content_type 'text/css'
    scss(:'stylesheets/documents')
  end

  post '/polls/coding' do
    p params
    redirect '/polls/coding'
  end
  
  get '/polls/coding' do
    #Database.connect_db_polls
    #a = CodingActivityContextsPoll.all.first
    #Database.disconnect_db_polls

    layout = :'layouts/main'
    content = slim(:'views/polls/coding_activity')
    slim(layout, :locals => { :content => content })
  end

  get '*' do  
    layout = :'layouts/main'
    begin
      slim(layout, :locals => { :content => markdown(@document_source.nil? ? @request_path.to_sym : @document_source), :metadatas => @metadatas })
    rescue
      halt 404, slim(layout, :locals => { :content => markdown(:'errors/404'), :metadatas => @metadatas })
    end
  end
  
end
