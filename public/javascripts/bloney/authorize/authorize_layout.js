///////////// Authorize Windows config Object
var config = {	closable : false,
				maximizable : false,
				resizable: false,
				buttonAlign: 'right',
				width : 530,
				height : 260,
				border : false,
				plain : false,
				shadow : false,
				layout : 'border',
				xbloney : 'default'
			};
///////////// Authorize Login Window 
BloneyLogin = function(config) {
	Ext.apply(this, config);
	
	this.login = new Ext.FormPanel({
		baseCls: 'x-plain',
		bodyStyle:'padding:30 0 0 100px',
		defaults : {
			autoScroll : true,
			width: 150
		},
		frame: false,
		id: 'login-form',
		xtype : 'form',
		defaultType: 'textfield',
		region: 'south',
		height: 120,
		url: '/authorize/login',
		labelWidth:120,
		layoutConfig: {
	        labelSeparator: ''
	    },
		items : [{
			id : 'login',
			fieldLabel : "<b>Login</b>",
			name : "login",
			allowBlank : false,
			blankText : "Please fill the Login"
		}, {
			id : 'password',
			fieldLabel : "<b>Password</b>",
			name : "password",
			allowBlank : false,
			blankText : "Please fill the Password",
			inputType : 'password'
		}/*,{
			xtype:"combo",
			fieldLabel:"Domain",
			name: "domain",
			id:"domain",
			store: new Ext.data.SimpleStore({
					fields: ['domain', 'domaindesc'],
					data : [['1','bloney.blogtery.com'],
						    ['0','blogtery.blogtery.com']]
			}),
			displayField:'domaindesc',
			valueField: 'domain',
			hiddenName: 'domainId',
			typeAhead: true,
			mode: 'local',
			triggerAction: 'all',
			emptyText:'Your domain',
			allowBlank : false,
			blankText : "Please choose the domain"
		}*/,{
			xtype : "checkbox",
			id : 'remember_me',
			fieldLabel : "Remember me",
			name : "remember_me",
			height: 20
		}]
	});
	
	this.logo = new Ext.Panel({
		//baseCls: 'x-plain',
		id: 'login-logo',
		region: 'center',
		html : '<div id="header-content"><h2 id="slogan">SOCIAL CASHFLOW</h2><h1 id="logo-text">Bloney</h1><div id="home"><div id="formhome"></div></div></div>'
	});

	BloneyLogin.superclass.constructor.call(this, {
		title : 'Bloney Cashflow',
		id: 'login-win',
		items : [this.logo, this.login],
		buttons : [
			
	{
					text : 'Forget Password',					
					handler : function(){
						Ext.getCmp('login-win').close();
						config.xbloney = 'forgot_password';
						var forgot_passwordWin = new BloneyAuthorizeWnd(config);
						forgot_passwordWin.show();
					}
				},{
					text : 'Sigup',
					handler : function(){
						Ext.getCmp('login-win').close();
						var signupWin = new BloneySignup(config);
						signupWin.show();
					}
				},
{
				text : 'Login',
				scope : 'BloneyLogin',
				handler : function(){							
							Ext.getCmp('login-form').getForm().submit({
								waitMsg:'Please Wait...',
								reset:true,
								success:function(f,a){									    
										if(a && a.result){
											Ext.getCmp('login-win').destroy(true);
											// set the cookie
											//set_cookie('sessionId', a.result.sessionId, '', path, '', '' );
											//set_cookie('memberName', a.result.name, '', path, '', '' );
											//set_cookie('memberGroup', a.result.group, '', path, '', '' );																			
											Ext.example.msg('Login', 'You {0}.</br>Bloney Cashflow ', a.result.notice);
											window.location = a.result.url;
									}
								},
								failure : function(f,a){									
									if(a && a.result){										
										Ext.example.msg('Login', '{0}.</br>Bloney Cashflow ', a.result.notice);
									}
								}
							});
				}
			}
		]
	});

};

Ext.extend(BloneyLogin, Ext.Window, {
	
});
///////////// Authorize SignUp Window
BloneySignup = function(config) {
	
	Ext.apply(this, config);
	
	if(config.xbloney == 'reset_password')
	{
		this.signup = new Ext.FormPanel({
			baseCls: 'x-plain',
			bodyStyle:'padding: 45 0 0 85px ',
			defaults : {
				autoScroll : true,
				width: 150
			},
			layoutConfig: {
		        labelSeparator: ''
		    },
			frame: false,
			id: 'signup-form',
			xtype : 'form',
			region: 'center',
			url:  '/authorize/reset_password',
			labelWidth:170,
			items : [ {
				xtype : "textfield",
				id : 'password',
				fieldLabel : "<b>Password</b> <i>(min 4 characters)</i>",
				name : "password",
				allowBlank : false,
				inputType : 'password',
				blankText : "Please complete the password"
			}, {
				xtype : "textfield",
				id : 'password_confirmation',
				fieldLabel : "<b>Confirm Password</b>",
				name : "password_confirmation",
				allowBlank : false,
				inputType : 'password',
				blankText : "Please complete the password"
			}]
		});
	}
	else
	{
		this.domainsstore = new Ext.data.Store({
		proxy: new Ext.data.HttpProxy({url: '/authorize/domains', method: 'GET'}),
		reader: new Ext.data.JsonReader({
				//id: 'title'
			}, ['domain','domain_description']),
			remoteSort: false
		});
		this.domainsstore.baseParams = {format : 'json'};
		this.domainsstore.load();
	
		this.signup = new Ext.FormPanel({
			baseCls: 'x-plain',
			bodyStyle:'padding: 45 0 0 85px ',
			defaults : {
				autoScroll : true,
				width: 150
			},
			layoutConfig: {
		        labelSeparator: ''
		    },
			frame: false,
			id: 'signup-form',
			xtype : 'form',
			region: 'center',
			url: '/authorize/signup',
			labelWidth:170,
			items : [{
				xtype : "textfield",
				id : 'login',
				fieldLabel : "<b>Login</b> <i>(min 3 characters)</i>",
				name : "login",
				allowBlank : (config.xbloney == 'reset_password') ? true : false,
				blankText : "Please complete the login"
			}, {
				xtype : "textfield",
				id : 'email',
				fieldLabel : "<b>Email</b> <i>(min 4 characters)</i>",
				name : "email",
				allowBlank : (config.xbloney == 'reset_password') ? true : false,
				inputType : 'email',
				blankText : "Please complete the email"
			}, {
				xtype : "textfield",
				id : 'password',
				fieldLabel : "<b>Password</b> <i>(min 4 characters)</i>",
				name : "password",
				allowBlank : false,
				inputType : 'password',
				blankText : "Please complete the password"
			}, {
				xtype : "textfield",
				id : 'password_confirmation',
				fieldLabel : "<b>Confirm Password</b>",
				name : "password_confirmation",
				allowBlank : false,
				inputType : 'password',
				blankText : "Please complete the password"
			},{
				xtype:"combo",
				fieldLabel:"<b>Domain</b>",
				id: 'domain_filter',
				store: this.domainsstore,
				displayField:'domain',
				valueField: 'domain',
				hiddenName: 'domainId',
				typeAhead: true,
				mode: 'local',
				triggerAction: 'all',
				emptyText:'Select a domain...'
			}]
		});
	}
	
	this.title = (config.xbloney == 'reset_password')? 'Save Changes' : 'Signup';
	BloneySignup.superclass.constructor.call(this, {
		title : 'Bloney Cashflow',
		id: 'signup-win',
		items : [ this.signup],
		buttons : [
				{
					text : 'Abort',
					scope : 'BloneySignup',
					handler : function(){
							Ext.getCmp('signup-win').close();
							var loginWin = new BloneyLogin(config);
							loginWin.show();
					}
				},{
					text : this.title,
					scope : 'BloneySignup',
					handler : function(){
								Ext.getCmp('signup-form').getForm().submit({
									waitMsg:'Please Wait...',
									reset:true,
									method:'POST',
									success:function(f,a){
											if(a && a.result){
												Ext.getCmp('signup-win').destroy(true);
												Ext.example.msg(this.title, '{0}.', a.result.notice);												
											    window.location = a.result.url;
										}
									},
									failure : function(f,a){				
										if(a && (a.result || a.response)){
											var notice = (a.result)? a.result.notice : a.response.statusText;
											Ext.example.msg(this.title, '{0}.',notice );
										}
									}
								});		
					}
				}			
			]
	});

};

Ext.extend(BloneySignup, Ext.Window, {

});
///////////// Authorize general Purpose Window
BloneyAuthorizeWnd = function(config) {
	
	Ext.apply(this, config);

	this.logo = new Ext.Panel({
		//baseCls: 'x-plain',
		id: 'login-logo',
		region: 'center',
		html : '<div id="header-content"><h2 id="slogan">SOCIAL CASHFLOW</h2><h1 id="logo-text">Bloney</h1><div id="home"><div id="formhome"></div></div></div>'
	});

	if((config.xbloney == 'welcome'))
	{
		this.southregion = new Ext.Panel({
		
			baseCls: 'x-plain',
			bodyStyle:'padding-left:50px',
			frame: false,
			id: 'welcome-form',
			xtype : 'border',
			region: 'south',
			height: 100,
			html: '<h1>Welcome to Bloney Cashflow</h1></br><p>You are just one step away from utilize the sophisticated cash flow engine. An activation mail has been sent to email address you provided. Follow the instructions in it to activate your account.</br>Thanks, The Bloney Cashflow Team</p>'
			});
	}
	else
	{	
		this.southregion = new Ext.FormPanel({
			baseCls: 'x-plain',
			bodyStyle:'padding: 45 0 0 85px ',
			defaults : {
				autoScroll : true,
				width: 150
			},
			frame: false,
			id: 'forget-form',
			xtype : 'form',
			defaultType: 'textfield',
			region: 'south',
			height: 120,
			url: '/authorize/forgot_password',
			labelWidth:170,
			layoutConfig: {
		        labelSeparator: ''
		    },
			items : [{
				id : 'email',
				fieldLabel : "<b>Email</b> <i>(min 4 characters)</i>",
				name : "email",
				allowBlank : false,
				inputType : 'email',
				blankText : "Please complete the email"
			}]
		});
	}
	
	
	BloneyAuthorizeWnd.superclass.constructor.call(this, {
		title : 'Bloney Cashflow',
		id: 'welcome-win',
		items : [this.logo
				,this.southregion],
		buttons : [{
					text : 'Abort',
					scope : 'BloneySignup',
					handler : function(){
							Ext.getCmp('welcome-win').close();
							var loginWin = new BloneyLogin(config);
							loginWin.show();
					}
				},
					{
					text : 'Request Password',
					hidden : ((config.xbloney == 'welcome') ? true : false),
					scope : 'BloneyAuthorizeWnd',
					handler : function(){
									Ext.getCmp('forget-form').getForm().submit({
									waitMsg:'Please Wait...',
									reset:true,
									method:'POST',
									success:function(f,a){
											if(a && a.result){
												Ext.getCmp('welcome-win').destroy(true);
												Ext.example.msg('Forget Password', '{0}', a.result.notice);												
											    window.location = a.result.url;
										}
									},
									failure : function(f,a){				
										if(a && (a.result || a.response)){
											var notice = (a.result)? a.result.notice : a.response.statusText;
											Ext.example.msg('Forget Password', '{0}.',notice );
											window.location = '/authorize/login';
										}
									}
								});		
					}
				}		
		]
	});

};

Ext.extend(BloneyAuthorizeWnd, Ext.Window, {
	
});


BloneyAuthorize = function() {
	version : "0.1"
}

BloneyAuthorize.prototype = {

	initBloneyAuthorize : function() {
		Ext.QuickTips.init();
		Ext.example.init();
		
		var path = document.location.pathname;
		var bloneyWin;
		
		if((path.lastIndexOf("/")== path.indexOf("/")) || path.match("login"))
		{
			bloneyWin = new BloneyLogin(config);
		}
		else if(path.match("signup"))
		{
			bloneyWin = new BloneySignup(config);
		}
		else if(path.match("activate"))
		{
			config.xbloney = 'activate';
			// must be redesigned in next review.
			Ext.example.msg('Activate', '{0}.', Ext.get("notice").dom.title);			
			bloneyWin = (Ext.get("success").dom.title == "true") ? new BloneyLogin(config) : new BloneySignup(config);	
		}
		else if(path.match("reset_password"))
		{
			config.xbloney = 'reset_password';
			bloneyWin = new BloneySignup(config);	
			bloneyWin.signup.getForm().baseParams = { id: path.substring(path.lastIndexOf("/")+1)};
		}
		else if(path.match("forgot_password"))
		{
			config.xbloney = 'forgot_password';
			bloneyWin = new BloneyAuthorizeWnd(config);
		}
		else if(path.match("welcome"))
		{
			config.xbloney = 'welcome';
			bloneyWin = new BloneyAuthorizeWnd(config);
		}
		else if(path.match("logout"))
		{
			bloneyWin = new BloneyLogin(config);
		}
		else if(path.match(""))
		{
			bloneyWin = new BloneyLogin(config);
		}
			
		bloneyWin.show();

		
	}
};

Ext.onReady(function() {
	var bloneyAuthorizeApp = new BloneyAuthorize();
	bloneyAuthorizeApp.initBloneyAuthorize();

});