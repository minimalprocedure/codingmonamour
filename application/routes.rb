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
    #Database.connect_db_polls
    begin
      params[:futures] = {:activities=>"f", :products_reuse=>"f", :sharing=>"f"} unless params[:futures]
      @activity = CodingActivityContextsPoll.new(params[:activity])
      if @activity.save
        params[:teacher_skills][:context_id] = @activity.id
        CodingActivityTeacherSkillsPoll.new(params[:teacher_skills]).save
        params[:projects][:context_id] = @activity.id
        CodingActivityProjectsPoll.new(params[:projects]).save
        params[:ratings][:context_id] = @activity.id
        CodingActivityRatingsPoll.new(params[:ratings]).save
        params[:futures][:context_id] = @activity.id
        CodingActivityFuturesPoll.new(params[:futures]).save
        flash.now[:success] = "Informazioni inviate, grazie."
      end
    rescue Sequel::ValidationFailed => e
      @activity.teacher_skills.destroy if @activity.teacher_skills
      @activity.projects.destroy if @activity.projects
      @activity.ratings.destroy if @activity.ratings
      @activity.futures.destroy if @activity.futures
      @activity.destroy if @activity.id
      errors = e.errors.keys.reduce("") {|a,k| a += "<div>#{e.errors[k][0]}</div>" }
      flash.now[:error] = "È occorso uno o più problemi di validazione: <br>" + errors
    rescue Exception => e
      flash.now[:error] = "È occorso un problema nel salvataggio delle informazioni. Riprovate se possibile, grazie."
    end
    #Database.disconnect_db_polls
    #redirect '/polls/coding'
    layout = :'layouts/main'
    content = slim(:'views/polls/coding_activity', :locals => {:polls => CodingActivityContextsPoll.all})
    slim(layout, :locals => { :content => content })
  end

  get '/polls/coding' do
    layout = :'layouts/main'
    params[:activity] = {}
    params[:teacher_skills] = {}
    params[:projects] = {}
    params[:ratings] = {}
    params[:futures] = {}
    @request_meta = File.join(settings.views, "views", "polls", "coding_activity.yml")
    @metadatas = settings.metadatas.merge( File.exist?(@request_meta) ? YAML.load_file(@request_meta).to_h : {})
    content = slim(:'views/polls/coding_activity', :locals => {:polls => CodingActivityContextsPoll.all})
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
