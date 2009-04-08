class AccountsController < ApplicationController
  #before_filter :login_required
  
  protect_from_forgery :only => [:create, :destroy]
  
  #access_control :DEFAULT => 'guest|admin|moderator'
  
  # GET /accounts
  # GET /accounts.xml
  def index
    @accounts = Account.find(:all,
                             :conditions=>"record_sts='ACTV'")
    
    if (@accounts.size == 0)
      @accounts << Account.new
      @accounts[0].customer_type = params[:account_type]
      @accounts[0][:authenticity_token] = form_authenticity_token
    else
      @accounts.map{|acc| acc[:authenticity_token] = form_authenticity_token }
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
      format.json { render :json => @accounts}
    end
  end
  
  def index_tree
    accounts = Account.find(:all,
                            #:select=>"id,account_no,account_type,balance",
                            :conditions=>"record_sts='ACTV'")
    accounts.map{|acc| acc[:authenticity_token] = form_authenticity_token
                       acc[:bank] = Bank.find(acc.bank_id) }  
                       
    accounts.map{|acc| acc[:leaf] = true 
                       acc[:uiProvider] = 'col'}
                       
    account_types = Account.find(:all, :select=>"distinct account_type") 
    
    account_types.each{|acctype| acctype[:uiProvider] = 'col'
                                 acctype[:authenticity_token] = form_authenticity_token
                                 acctype[:children] = accounts.find_all {|acc| acc.account_type == acctype.account_type } }
       
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => account_types }
      format.json { render :json => account_types}
    end
  end
  
  def virtual_tree
    accounts = Account.find(:all,
                            :select=>"id,account_no,account_type,balance",
                            :conditions=>"record_sts='ACTV'")
                            
   accounts.map{|acc| acc[:leaf] = true 
                      acc[:text] = acc.account_no}
                       
       
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => accounts }
      format.json { render :json => accounts}
    end
  end 
  
  # -- BATCHES
  def postdirectory
    
    accounts_hash(params)
    params[:folder_name]=String.new("accounts")
    params[:file_name]=String.new("accounts")
    post_directory(params){@accounts_hash.to_yaml}
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                        notice:'Accounts directory posted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def adoptdirectory
   
    accounts = YAML::load(File.open("#{RAILS_ROOT}/db/shared/accounts/accounts.yml" ))
    accounts[:Accounts].each do |item| 
      inject_accounts (item) 
     end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Accounts directory adopted sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def cleandirectory
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PUBLIC')
      Dir.chdir("#{RAILS_ROOT}/db/shared/accounts")
      FileUtils.rm Dir.glob("accounts.yml")
    #end
    
    #if (params[:share_type].eql? 'ALL' or params[:share_type].eql? 'PRIVATE')
    #  Dir.chdir("#{RAILS_ROOT}/db/shared/customers")
    #  FileUtils.rm Dir.glob("#{session[:company].customer_name}*.yml") 
    #end
    
    respond_to do |format|
      format.html { 
        render :text=>"{success:true,
                          notice:'Accounts directory cleaned sucessfully.' }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def accounts_sharelist
    accounts_list = Array.new
    FileUtils.mkdir_p("#{RAILS_ROOT}/db/shared/accounts")
    Dir.foreach("#{RAILS_ROOT}/db/shared/accounts") { |x| accounts_list.push({:name => x.sub(/.yml/,'')}) if (x != '.' and x != '..') }
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => accounts_list.to_xml }
      format.json { render :json => accounts_list.to_json}
    end
  end
  
  # --  INDIVIDUAL
  # instance methods for cross-domain remote calls
  # GET /accounts/index_remote
  def index_remote
   
    accounts_hash(params)
  
    respond_to do |format|
      format.js { render :js => "#{params[:jsoncallback]}(#{account_list.to_json()});" }
      format.chr {render :chr=>@accounts_hash}
      format.jsonc {render :jsonc=>@accounts_hash}
    end
  end
  
  # GET /accounts/create_remote
  def create_remote
    @reply_remote = Hash.new()
    
    unless params[:account].nil?
        account = ActiveSupport::JSON.decode(params[:account]).rehash
        inject_account(account)
        @reply_remote[:success]= true
        @reply_remote[:notice] = 'Account was successfully created.'
    else
       @reply_remote[:success]= false
    end
    
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /accounts/update_remote/1
  def update_remote
    @reply_remote = Hash.new()
    
    unless params[:account].nil?
      account = ActiveSupport::JSON.decode(params[:account]).rehash
      @account = Account.find(account["accountId"])
      @account.update_attributes(account)
      @reply_remote[:success]= true
      @reply_remote[:notice] = 'Account was successfully updated.'
   else
       @reply_remote[:success]= false
   end
 
    respond_to do |format|
        format.js { render :js => "#{params[:jsoncallback]}(#{@reply_remote.to_json});" }
        format.chr {render :chr=> @reply_remote }
        format.jsonc { render :jsonc=> @reply_remote  }
    end
  end
  
  # GET /accounts/destroy_remote/1
  def destroy_remote
    @account = Account.find(params[:accountId])
    @reply_remote = Hash.new()
    
    unless @account.nil?
       @account.destroy
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
  
  def accounts_hash (params)
    if params[:accountId].nil?
    @accounts ||= Account.find(:all)
   else
    @accounts ||= Account.find(params[:accountId])
   end
    accounts_list = @accounts.map {|account| 
                 {
                  :accountId=>account.id,
                  :contact_id=>account.contact.id,
                  :account_no=>account.account_no,
                  :account_type=>account.account_type,
                  :currency=>account.currency,
                  :balance=>account.balance,
                  :balance_date=>account.balance_date,
                  :credit_limit=>account.credit_limit
                  }
          }
          
    @accounts_hash = Hash.new
    @accounts_hash[:Accounts] = accounts_list   
    @accounts_hash[:Total] = accounts_list.size
  end
  
  def inject_accounts (account)
       #if required the filtr should be here 
      account.delete(:accountId)
       # ToDo check if record already exists
      Account.create(account)
  end
end
