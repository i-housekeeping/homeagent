class CashrecordsController < ApplicationController
  #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
    
  def upload
      file = params[params[:input_id]].read
      file_name = params[params[:input_id]].original_filename
      logger.warn " File name : " + file_name
      FileUtils.mkdir_p("#{RAILS_ROOT}/db/upload/cashrecords")
      File.open("#{RAILS_ROOT}/db/upload/cashrecords/#{file_name}", 'wb') {|f| f.write(file) }
      render :text=>"{success:true}", :layout=>false
  end
  
  def set_cashrecords_params (params)
    last_record = Cashrecord.find(:first, 
                                  :conditions => "value_date <= '#{params[:value_date].to_s}'",
                                  :order=>"value_date DESC, id DESC")
                                  
    current_balance = (last_record.nil? ? 0.00 : last_record[:current_balance].to_f ) - params[:debit_amount].to_f + params[:credit_amount].to_f
    logger.warn "Last record balance : " + current_balance.to_s

    params[:cashrecord] = {
      :cid=>params[:cashrecords_id],
      :account_id=>1,
      :category_id =>params[:category_id],
      :customer_id=>params[:customer_id],
      :cashrec_type=>params[:cashtype],
      :cashrec_status=>'ACTV',
      :debit_amount=>params[:debit_amount],
      :credit_amount=>params[:credit_amount],
      :current_balance=> current_balance.to_s,
      :currency=>'BLN',
      :reference=>params[:reference],
      :details=>params[:details],
      :value_date=>params[:value_date],
      :balance_date=>params[:balanceajustement],
      :repetitive_type=>params[:repetitionId],
      :record_seq=>1,
      :total_records=>params[:numpayments],
      :repetitive_amount=>params[:totalamount],
      :starting_date=>params[:startdate]
    }
  end
  
  def update_current_balance (params)
    update_records = Cashrecord.find(:all, 
                                  :conditions => "value_date > '#{params[:cashrecord][:value_date].to_s}'",
                                  :order=>" id DESC")
    
    if !update_records.nil?    
      logger.warn "Update records balanace #{update_records.size}"
      update_records.each do |rec| 
          rec.current_balance += (params[:credit_amount].to_f - params[:debit_amount].to_f)
          rec.save
      end
    end                             
  end
  
  def set_repetetive_values (params, iteration)
    
    logger.warn "Class #{params[:cashrecord][:value_date].class}"
    
    if iteration == 1
      params[:cashrecord][:value_date] = Date.strptime(params[:startdate], '%Y-%m-%d')
    else
      case params[:repetitionId]
        when 'DAY' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].tomorrow()
        when 'WEEK' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].advance(:days=>7)
        when 'TWOWEEK' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].advance(:days=>14)
        when 'MONTH' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].next_month()
        when 'QUARTER' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].months_since(3)
        when 'HALFYEAR' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].months_since(6)
        when 'YEAR' then params[:cashrecord][:value_date] = params[:cashrecord][:value_date].next_year()
        else
      end
    end
    
    last_record = Cashrecord.find(:first,:conditions => "value_date <= '#{params[:cashrecord][:value_date].to_s}'",
                                  :order=>"value_date DESC, id DESC")
                                  
    params[:cashrecord][:current_balance] = (last_record.nil? ? 0.00 : last_record[:current_balance].to_f ) - params[:debit_amount].to_f + params[:credit_amount].to_f
    params[:cashrecord][:record_seq] = iteration.to_s

    logger.warn "New value date for #{params[:cashrecord][:record_seq]} iteration is #{params[:cashrecord][:value_date]}"
  end
  
  def stories
    return_data = Hash.new()
    return_data [:data] = Cashrecord.find(params[:id]).stories
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => return_data }
      format.json { render :json => return_data}
    end
  end
  
  ###################################################################################################################
  #  NEED REVIEW
  
  def list
    value_date = Date.strptime(params[:value_date], '%Y-%m-%d')
   
    return_data = Hash.new()
    
    @cashrecords = Cashrecord.find( :all, 
                                   :select => "id,cid, account_id, category_id, cashrec_type, debit_amount, credit_amount, currency, value_date",
                                   :conditions => "value_date = '#{value_date.to_s}' and cashrec_status = 'ACTV'" )
    
    if (@cashrecords.size == 0)
      @cashrecords << Cashrecord.new
      @cashrecords[0][:authenticity_token] = form_authenticity_token
    else
      @cashrecords.map do|cash| 
          cash[:authenticity_token] = form_authenticity_token 
          cash[:category_name] = cash.category.text 
          cash[:account_no] = cash.account.account_no
        end
    end
    
    logger.info "---------------------"
    logger.info @cashrecords.to_json
    return_data[:Cashrecords] = @cashrecords
    return_data[:Total] = @cashrecords.size 
    logger.info "---------------------"
    render :text=>return_data.to_json, :layout=>false
  end
  
  def user_histories
    start_day  = Date.strptime(params[:start_day], '%Y-%m-%d')
    cashrec_status = params[:cashrec_status]
    if cashrec_status.nil? || cashrec_status.empty?
      cashrec_status='ACTV'
    end
    days_in_month = Date::civil(start_day.year, start_day.month, -1).day
    first_day = Date.new(start_day.year, start_day.month,1)
    last_day = Date.new(start_day.year, start_day.month,days_in_month)
    @cashrecords = Cashrecord.find(:all, 
                                   :select => "value_date, cashrec_type, cid,cashrec_status",
    :group => "value_date, cashrec_type" ,
    :conditions => "value_date >= '#{first_day.to_s}' AND value_date <= '#{last_day.to_s}' and cashrec_status = '#{cashrec_status}'"
    )
    
    
    cCASHREC_TYPES = %w[debit credit antidebit anticredit]
    logger.info cCASHREC_TYPES[1].to_s  
    
    return_data = cCASHREC_TYPES.collect{|m|
      {
        :children => history_details(@cashrecords.select{ |ch| ch.cashrec_type == m.to_s},
        Date::civil(start_day.year, start_day.month, 1) ),
        :leaf=>false,
        :cls=>"folder",
        :text=>m.to_s,
        :id=>m.to_s
      }
    }
    
    render :text=>return_data.to_json, :layout=>false
  end
  
  def history
    
    start_day  = Date.strptime(params[:start_day], '%Y-%m-%d')
    
    @cashrec_history = CashrecordHistory.find(
                                              :all, 
                                              :select => "cid,description,cashrec_type,cashrec_status,update_date",
    :conditions => "update_date like '#{start_day.strftime('%Y-').to_s}%'",
    :order=> "update_date ASC"
    )
    
    return_data = (1..12).collect{|m|  
      {
        :children => history_details(@cashrec_history.select{ |ch| ch.update_date[5,2].to_s == m.to_s },
        Date::civil(start_day.year, m, 1) ),
        :leaf=>false,
        :cls=>"folder",
        :text=>DateTime::now().year().to_s+"_"+ Date::MONTHNAMES[m],
        :id=>m.to_s
      }
    }
    
    render :text=>return_data.to_json, :layout=>false
  end
  
  def history_details(cashrec_history, start_day)
    
    days_in_month = Date::civil(start_day.year, start_day.month, -1).day
    return_data =  Array.new()
    
    for current_day in (1..days_in_month)
      
      start_day=Date::civil(start_day.year, start_day.month,current_day )
      
      filtered_data = cashrec_history.select{ |ch|
        ch.value_date.to_s == start_day.to_s
      }
      
      if(!filtered_data.nil? and !filtered_data.empty?)
        return_data.push({
          :children => history_cashrecords(filtered_data) ,
          :leaf=>false,
          :cls=>"folder",
          :text=>start_day.to_s + " ("+ filtered_data.size().to_s + ")",
          :id=>start_day.to_s
        })
      end
    end
    
    return_data
    
  end
  
  
  def history_cashrecords(cashrecords)
    return_data = Array.new()
    
    cashrecords.each{|c|
      return_data.push({
        :leaf=>true,
        :cls=>"file",
        :text=>c.cashrec_type,
        :id=>c.cid.to_s
      }) 
    }
    
    return_data
  end
  
  # Called from the list page to get the cashrecords list data to populate the grid.
  def grid_data
    
    start_day  = Date.strptime(params[:start_day], '%Y-%m-%d')
    cashrec_status = params[:cashrec_status]
    if cashrec_status.nil? || cashrec_status.empty?
      cashrec_status='ACTV'
    end
    
    days_in_month = Date::civil(start_day.year, start_day.month, -1).day
    first_day = Date.new(start_day.year, start_day.month,1)
    last_day = Date.new(start_day.year, start_day.month,days_in_month)
    
    @cashrecords = Cashrecord.find(:all, 
                                   :select => "value_date, cashrec_type, debit_amount, credit_amount, current_balance",
                                   #:group => "value_date, cashrec_type" ,
                                   :conditions => "value_date >= '#{first_day.to_s}' AND value_date <= '#{last_day.to_s}' and cashrec_status = '#{cashrec_status}'"                      
    #:limit=>@cashrecords_pages.items_per_page,
    #:offset=>@cashrecords_pages.current.offset, 
    #:order=>sort_col+' '+sort_dir
    )
    @cashrecords.each {|u| logger.info u.value_date }
    @cashrecords.each {|u| logger.info u.cashrec_type }
    @cashrecords.each {|u| logger.info u.debit_amount }
    @cashrecords.each {|u| logger.info u.credit_amount }
    @cashrecords.each {|u| logger.info u.current_balance }
    record = Cashrecord.find(:first,                                    
                              :conditions => "value_date < '#{first_day.to_s}'",  
                              :order=>"value_date DESC, id DESC")
                              
    current_balance = record.nil? ? 0.00 : record[:current_balance].to_f
    logger.warn "Current amount on previous month : #{current_balance.to_s}"
    return_data = Hash.new()      
    return_data[:Total] = days_in_month
    return_data[:Cashrecords] = (1..days_in_month).collect{|u|
      {:id=>u , 
        :date=>(Date.new(start_day.year, start_day.month,u)).to_s,
        :day=>Date::ABBR_DAYNAMES[(Date.new(start_day.year, start_day.month,u)).wday], 
        :debit=>(filter_date_type( Date.new(start_day.year, start_day.month,u), 'debit')).to_s,
        :credit=>(filter_date_type( Date.new(start_day.year, start_day.month,u), 'credit')).to_s,
        :antidebit=>(filter_date_type( Date.new(start_day.year, start_day.month,u), 'antidebit')).to_s,
        :anticredit=>(filter_date_type( Date.new(start_day.year, start_day.month,u), 'anticredit')).to_s,
        :total=>(current_balance += filter_date( Date.new(start_day.year, start_day.month,u))).to_s
      } }
    
    render :text=>return_data.to_json, :layout=>false
  end
  
  def filter_date_type( date, type)
    amount = 0.00
    @cashrecords.each do |c| if(c.value_date.to_s == date.to_s && c.cashrec_type == type.to_s) 
                  amount+= ((type.include? "debit") ? c.debit_amount.to_f : c.credit_amount.to_f)  
                  logger.warn "Amount #{type} on #{date.to_s} = #{amount.to_s } "  
          end 
        end
    ("%.2f" % amount).to_f
  end
  
  def filter_date( date)
    amount = 0.00
    @cashrecords.each do |c| if(c.value_date.to_s == date.to_s) 
          amount += (c.credit_amount.to_f - c.debit_amount.to_f) 
          logger.warn "Amount on #{date.to_s} = #{amount.to_s } " 
        end 
     end
    ("%.2f" % amount).to_f
  end
  
  def filter_type( type)
    amount = 0.00
    @cashrecords.each {|c| if( c.cashrec_type == type.to_s) 
        amount+= ((type.include? "debit") ? c.debit_amount.to_f : c.credit_amount.to_f)end }
    ("%.2f" % amount).to_f
  end
  
  # -- BATCHES
  def postdirectory
    
    cashrecords_hash(params)
    params[:folder_name]=String.new("cashrecords")
    params[:file_name]=String.new("cashrecords")
    post_directory(params){@cashrecords_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Cashrecords directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    cashrecords = YAML::load(File.open("#{RAILS_ROOT}/db/shared/cashrecords/cashrecords.yml" ))
    cashrecords[:Cashrecords].each do |item| 
      inject_cashrecords (item) 
     end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Cashrecords directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/cashrecords")
      FileUtils.rm Dir.glob("cashrecords.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Cashrecords directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cashrecords_sharelist
    cashrecords_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/cashrecords")
    Dir.foreach("#{RAILS_ROOT}/db/shared/cashrecords") { |x| cashrecords_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => cashrecords_list.to_xml }
      format.json { render :json => cashrecords_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /cashrecords/index_remote
  def index_remote
   
    cashrecords_hash(params)
  
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{cashrecord_list.to_json()});" }
      format.chr {render :chr=>@cashrecords_hash}
      format.jsonc {render :jsonc=>@cashrecords_hash}
    end
  end
  
  # GET /cashrecords/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:cashrecord].nil?
        cashrecord = ActiveSupport::JSON.decode(params[:cashrecord]).rehash
        inject_cashrecord(cashrecord)
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'Cashrecord was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /cashrecords/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:cashrecord].nil?
      cashrecord = ActiveSupport::JSON.decode(params[:cashrecord]).rehash
      @cashrecord = Cashrecord.find(cashrecord["cashrecordId"])
      @cashrecord.update_attributes(cashrecord)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'Cashrecord was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /cashrecords/destroy_remote/1
  def destroy_remote
    @cashrecord = Cashrecord.find(params[:cashrecordId])
    @reply_remote = Hash.new()
    
    unless @cashrecord.nil?
       @cashrecord.destroy
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
  
  def cashrecords_hash (params)
    if params[:cashrecordId].nil?
    @cashrecords ||= Cashrecord.find(:all)
   else
    @cashrecords ||= Cashrecord.find(params[:cashrecordId])
   end
    cashrecords_list = @cashrecords.map {|cashrecord| 
                 {
                    :cashrecordId=>cashrecord.id,
                    :user_id=>cookies[:current_user_id], 
                    :task_id=>cashrecord.task.id, 
                    :cashrec_type=>cashrecord.cashrec_type,
                    :reference=>cashrecord.reference,
                    :dr_account_id=>cashrecord.dr_account_id,
                    :debit_amount=>cashrecord.debit_amount,
                    :dr_value_date=>cashrecord.dr_value_date,
                    :cr_account_id=>cashrecord.cr_account_id,
                    :credit_amount=>cashrecord.credit_amount,
                    :cr_value_date=>cashrecord.cr_value_date,
                    :original_balance=>cashrecord.original_balance,    
                    :repetitive_type=>cashrecord.repetitive_type,
                    :record_sequence=>cashrecord.record_sequence,
                    :total_records=>cashrecord.total_records,
                    :repetitive_amount=>cashrecord.repetitive_amount,
                    :starting_date=>cashrecord.starting_date,
                    :details=>cashrecord.details
                  }
          }
          
    @cashrecords_hash = Hash.new
    @cashrecords_hash[:Cashrecords] = cashrecords_list   
    @cashrecords_hash[:Total] = cashrecords_list.size
  end
  
  def inject_cashrecords (cashrecord)
       #if required the filtr should be here 
      cashrecord.delete(:cashrecordId)
       # ToDo check if record already exists
      Cashrecord.create(cashrecord)
  end
  
  
end
