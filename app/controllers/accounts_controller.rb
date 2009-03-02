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
  
  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @account = Account.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = Account.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end
  
  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end
  
  # POST /accounts
  # POST /accounts.xml
  def create
    set_account_params params
    @account = Account.new(params[:account])
    
    respond_to do |format|
      if @account.save
        Story.new().create_story(@account, current_user)
        format.html { 
          render :text=>"{success:true,
                          notice:'Account #{params[:account][:account_no]} was successfully created.'}", :layout=>false
        }
        format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = Account.find(params[:account_id])
    set_account_params params
    
    respond_to do |format|
      if @account.update_attributes(params[:account])
        Story.new().update_story(@account, current_user,params[:story])
        format.html { 
          render :text=>"{success:true,
                          notice:'Account #{params[:account][:account_no]} was successfully updated.'}", :layout=>false
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = Account.find(params[:account_id])
    @account.destroy
    Story.new().delete_story(@account, current_user)
    
    respond_to do |format|
      format.html {  
        render :text=>"{success:true }", :layout=>false
      }
      format.xml  { head :ok }
    end
  end
  
  def stories
    return_data = Hash.new()
    return_data [:data] = Account.find((params[:id].to_i == 0) ? :first : params[:id]).stories 
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => return_data }
      format.json { render :json => return_data}
    end
  end
  
  def set_account_params (params)
    params[:account] = {
      :account_no=>params[:accountnumber],
      :account_type=>params[:accounttype],
      :currency=>params[:accountcurrency],
      :balance=>params[:accountbalance],
      :credit_limit=>params[:accountcrlimit],
      :balance_date=>params[:accountbalancedate]
    }
  end
end
