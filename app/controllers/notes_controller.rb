class NotesController < ApplicationController
 # -- BATCHES
  def postdirectory
    
    notes_hash(params)
    params[:folder_name]=String.new("notes")
    params[:file_name]=String.new("notes")
    post_directory(params){@notes_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Notes directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    notes = YAML::load(File.open("#{RAILS_ROOT}/db/shared/notes/notes.yml" ))
    notes[:Notes].each do |item| 
      inject_notes (item) 
     end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Notes directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/notes")
      FileUtils.rm Dir.glob("notes.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Notes directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def notes_sharelist
    notes_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/notes")
    Dir.foreach("#{RAILS_ROOT}/db/shared/notes") { |x| notes_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => notes_list.to_xml }
      format.json { render :json => notes_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /notes/index_remote
  def index_remote
   
    notes_hash(params)
  
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{note_list.to_json()});" }
      format.chr {render :chr=>@notes_hash}
      format.jsonc {render :jsonc=>@notes_hash}
    end
  end
  
  # GET /notes/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:note].nil?
        note = ActiveSupport::JSON.decode(params[:note]).rehash
        inject_note(note)
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'Note was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /notes/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:note].nil?
      note = ActiveSupport::JSON.decode(params[:note]).rehash
      @note = Note.find(note["noteId"])
      @note.update_attributes(note)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'Note was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /notes/destroy_remote/1
  def destroy_remote
    @note = note.find(params[:noteId])
    @reply_remote = Hash.new()
    
    unless @note.nil?
       @note.destroy
       @reply_remote[:success]= true
    else
       @reply_remote[:success]= false
    end
   
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
      format.chr {render :chr=> @reply_remote}
      format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  private
  
  def notes_hash (params)
    if params[:noteId].nil?
    @notes ||= Note.find(:all)
   else
    @notes ||= Note.find(params[:noteId])
   end
    notes_list = @notes.map {|note| 
                 {
                    :noteId=>note.id,
                    :user_id=>note.user_id,
                    :title=>note.title,
                    :note=>note.note,
                    :note_type=>note.note_type,
                    :last_update=>note.last_update
                  }
          }
          
    @notes_hash = Hash.new
    @notes_hash[:Notes] = notes_list   
    @notes_hash[:Total] = notes_list.size
  end
  
  def inject_notes (note)
       #if required the filtr should be here 
      note.delete(:noteId)
       # ToDo check if record already exists
      Note.create(note)
  end
end
