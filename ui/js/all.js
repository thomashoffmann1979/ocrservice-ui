riot.tag('app', '<nav class="navbar navbar-default navbar-fixed-top"> <div class="container-fluid"> <div class="navbar-header"> <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-collapse-1"> <span class="icon-bar"></span> <span class="icon-bar"></span> <span class="icon-bar"></span> </button> <a class="navbar-brand" href="#"><i class="fa fa-envelope-o fa-lg"></i></a> </div> <div class="collapse navbar-collapse" id="bs-collapse-1"> <discovery></discovery> <ul class="nav navbar-nav pull-right"> <li><a href="#" onclick="{ inspect }">Inspect</a></li> <li><a href="#" onclick="{ exit }">Exit</a></li> <li> <a href="#"> <i class="fa fa-wifi icon-{ connected ? (loggedin?\'green\':\'yellow\') : \'red\' }"></i>{message}</a> </li> </ul> </div> </div> </nav> <br> <br> <br> <wait class="{ wait ? \'show\' : \'hide\' }"></wait> <login class="{ login ? \'show\' : \'hide\' }"></login> <letter class="{ letter ? \'show\' : \'hide\' }"></letter> </div> </div>', function(opts) {

    var states = ['wait','login','letter'];
    for(var i=0;i<states.length;i++){
      this[states[i]] = false;
    }
    var me = this;


    setTimeout(function(){
      me.state = 'login';
      riot.update();
    },5000);


    this.inspect = function(e) {
      require('nw.gui').Window.get().showDevTools();
    }.bind(this);

    this.exit = function(e) {
      var gui = require('nw.gui');
      gui.App.quit();
    }.bind(this);


    window.app = me;

    this.setState = function(state) {
      for(var i=0;i<states.length;i++){
        this[states[i]] = false;
      }
      this[state] = true;
      riot.update();
    }.bind(this);
    this.switchToAddress = function(url) {
      if (typeof me.socket!=='undefined'){
        me.socket.close()
      }
      me.socket = io(url);
      me.socket.on('connect', me.socketConnect.bind(me) );
      me.socket.on('disconnect', me.socketDisconnect.bind(me) );
      me.socket.on('loginRequired', me.socketLoginRequired.bind(me) );
      me.socket.on('loginError', me.socketLoginError.bind(me) );
      me.socket.on('letter', me.socketLetter.bind(me) );
      me.socket.on('checked', me.socketChecked.bind(me) );
      
    }.bind(this);

    this.socketConnect = function() {
      me.message = "Verbunden";
      me.connected=true;
      riot.update();
    }.bind(this);

    this.socketDisconnect = function() {
      me.message = "Verbindung suchen ...";
      me.connected=false;
      me.current = null;
      riot.update();
    }.bind(this);

    this.socketLoginError = function(msg) {
      alert(msg);
      me.loggedin=false;

    }.bind(this);

    this.socketLetter = function(msg) {
      console.log('socketLetter',msg);
      
      me.loggedin=true;
      me.message = "Sendung erfassen";

      me.current.street = "";
      me.current.id = "";
      me.current.zipCode = "";
      me.current.housenumber = "";
      me.current.housenumberExtension = "";

      me.currentBoxesOk=false;
      me.currentBoxes=[];

      me.current = msg;

      me.currentLoaded = true;
      me.setState('letter');
      me.trigger('new');
      riot.update();
    }.bind(this);

    this.socketChecked = function(msg) {
      if (msg.length>0){
        if (typeof msg[0].box!=='undefined'){
          if (me.current.id == msg[0].id){
            if (msg[0].box.length>0){
              me.currentBoxes = msg[0].box;
              me.currentBoxesOk = false;

              if (msg[0].box.length===1){

                me.currentBoxesOk = true;

                me.current.street = msg[0].street;
                me.current.zipCode = msg[0].zipCode;
                me.current.town = msg[0].town;
                me.current.housenumber = msg[0].housenumber;
                me.current.housenumberExtension = msg[0].housenumberExtension;
              }
            }
          }
        }
      }

      riot.update();
    }.bind(this);

    this.socketLoginRequired = function() {
      me.message = "Anmeldung benötigt";
      me.setState('login');
      me.loggedin=false;
      riot.update();
    }.bind(this);

    me.current = {};
    me.currentBoxes=[];
    me.currentBoxesOk=false;
    me.currentLoaded =false;
    me.socket;
    me.setState('wait');
  
});

riot.tag('discovery', '<ul class="nav navbar-nav"> <li each="{ serviceList }" > <a href="#" onclick="{ parent.switchTo }" data-address="{address}">{address}</a> </li> </ul>', function(opts) {

    var me = this;
    me.discovery = new updfindme.Discovery(32145);
    me.serviceList = [];
    me.serviceHash = {};

    me.discovery.on('found',function(data,remote){
      if (data.type === 'ocrservice'){
        if (typeof me.serviceHash[ remote.address ]=='undefined'){
          me.serviceHash[ remote.address ] = data.port;
          data.address = remote.address;
          me.serviceList.push(data);
          riot.update();
          if (typeof socket==='undefined'){
            me.goTo(data.address);
          }
        }
      }
    });

    me.discovery.on('timeout',function(data){
      setTimeout(function(){
        me.discovery.discover()
      },15000)
    });
    me.discovery.discover();

    this.goTo = function(address) {
      window.app.switchToAddress( 'http://'+address+':'+me.serviceHash[ address ] )
    }.bind(this);

    this.switchTo = function(e) {
      me.goTo(e.target.dataset.address);
    }.bind(this);

  
});

riot.tag('letter', '<div class="container-fluid" id="fluidform"> <form id="letterform"> <div class="row"> <div class="col-md-4"> <div class="form-group"> <label for="inputID" class="col-sm-2 control-label">ID</label> <div class="col-sm-10"> <input value="{ current.id }" type="text" name="id" class="form-control" id="inputID" placeholder="Login" onkeypress="{keypress}" onblur="{check}" > </div> </div> <div class="form-group"> <label for="inputZipCode" class="col-sm-2 control-label">PLZ</label> <div class="col-sm-10"> <input value="{ current.zipCode }" type="text" name="zipCode" class="form-control" id="inputZipCode" placeholder="PLZ" onkeypress="{keypress}" onblur="{check}" > </div> </div> </div> <div class="col-md-4"> <div class="form-group"> <label for="inputStreet" class="col-sm-2 control-label">Straße</label> <div class="col-sm-10"> <input name="street" value="{ current.street }" type="text" class="form-control" placeholder="Strasse" id="inputStreet" onkeypress="{keypress}" onblur="{check}"> </div> </div> <div class="form-group"> <label for="inputHousenumber" class="col-sm-2 control-label">HN</label> <div class="col-sm-7"> <input name="housenumber" value="{ current.housenumber }" type="text" class="form-control" placeholder="Hausnummer" id="inputHousenumber" onkeypress="{keypress}" onblur="{check}"> </div> <div class="col-sm-3"> <input name="housenumberExtension" value="{ current.housenumberExtension }" type="text" class="form-control" placeholder="Hausnummer" onkeypress="{keypress}" onblur="{check}"> </div> </div> </div> <div class="col-md-4"> <ul> <li each ="{currentBoxes}">SG{sortiergang} SF{sortierfach}</li> </ul> <br> <button accesskey="s" type="button" class="btn btn-{currentBoxesOk?\'success\':\'default\'}" onclick="{ submit }" >Speicher [S]</button> <button accesskey="n" type="button" class="btn btn-info" onclick="{ skip }" >Skip [N]</button> <button accesskey="b" type="button" class="btn btn-warning" onclick="{ bad }" >Bad [B]</button> </div> </div> <form> <br> </div> <div class="container" > <div class="row"> <img id="image" class="letterimg" height="300" riot-src="{ current.inlineimage }"> </div> </div>', function(opts) {
    var me = this;
    var socket;
    var me = this;
    var inputOrder = ['id','zipCode','street','housenumber','housenumberExtension'];
    me.current = window.app.current;
    me.currentBoxes = window.app.currentBoxes;
    me.currentBoxesOk = window.app.currentBoxesOk;

    window.app.on('new',function(){
      me.letterform[inputOrder[0]].focus();
      me.letterform[inputOrder[0]].select();

      me.check({});
    });

    me.on('mount update unmount', function(eventName) {
      var img= window.document.getElementById('image');
      if (img!==null){
        img.height = $(window).height() - $('#fluidform').height() - 100;
      }
      me.current = window.app.current;
      me.currentBoxes = window.app.currentBoxes;
      me.currentBoxesOk = window.app.currentBoxesOk;
      if (eventName==='mount'){
        try{
          me.letterform[inputOrder[0]].focus();
          me.letterform[inputOrder[0]].select();
        }catch(e){

        }
      }
    });


    this.submit = function(e) {
      if (me.currentBoxesOk===true){
        me.message = "Senden ...";
        var data = {
          id: this.letterform.id.value,
          zipCode: this.letterform.zipCode.value,
          street: this.letterform.street.value,
          housenumber: this.letterform.housenumber.value,
          housenumberExtension: this.letterform.housenumberExtension.value
        }
        window.app.socket.emit('save',data);
        riot.update();
      }
    }.bind(this);

    this.check = function(e) {
      var data = {
        id: this.letterform.id.value,
        zipCode: this.letterform.zipCode.value,
        street: this.letterform.street.value,
        housenumber: this.letterform.housenumber.value,
        housenumberExtension: this.letterform.housenumberExtension.value
      }
      console.log('check',data);
      window.app.socket.emit('check',data);
    }.bind(this);


    this.skip = function(e) {
      window.app.message = "Senden ...";
      window.app.setState('wait');
      data = {
        id: this.letterform.id.value
      }
      window.app.socket.emit('skip',data);
      riot.update();
    }.bind(this);

    this.bad = function(e) {
      window.app.message = "Senden ...";
      window.app.setState('wait');
      data = {
        id: this.letterform.id.value
      }
      window.app.socket.emit('bad',data);
      riot.update();
    }.bind(this);

    this.keypress = function(e) {
      var index
      if (e.which === 13){
        index = inputOrder.indexOf(e.target.name);
        if (index<inputOrder.length-1){
          index++;
        }else{
          index=0;
        }
        this.letterform[inputOrder[index]].focus();
        this.letterform[inputOrder[index]].select();
      }
      console.log(e);
      return true;
    }.bind(this);

  
});

riot.tag('login', '<div class="container-fluid"> <div class="row"> <div class="col-md-12"> <div class="panel panel-default"> <div class="panel-heading"> <h3 class="panel-title">Anmelden</h3> </div> <div class="panel-body"> <form id="loginform"> <div class="form-group"> <label for="inputLogin" class="col-sm-2 control-label">Login</label> <div class="col-sm-10"> <input value="{ login }" type="text" name="login" class="form-control" id="inputLogin" placeholder="Login" onkeypress="{keypress}" > </div> </div> <div class="form-group"> <label for="inputPassword" class="col-sm-2 control-label">Passwort</label> <div class="col-sm-10"> <input value="{ password }" name="password" type="password" class="form-control" placeholder="Password" id="inputPassword" onkeypress="{keypress}"> </div> </div> <div class="form-group"> <div class="col-sm-offset-2 col-sm-10"> <div class="checkbox"> <label> <input name="remember" type="checkbox">merken </label> </div> </div> </div> <div class="form-group"> <div class="col-sm-offset-2 col-sm-10"> <button type="button" class="btn btn-default" onclick="{ submit }">Anmelden</button> </div> </div> <form> </div> </div> </div> </div> </div>', function(opts) {
    var inputOrder = ['login','password'];
    var me = this;
    me.login = localStorage.getItem("login")
    me.password = localStorage.getItem("password")
    if (me.login===null){
      me.login = ""
    }
    if (me.password===null){
      me.password = ""
    }

    if (me.login.length>0){
      me.loginform.remember.checked = true;
    }

    this.submit = function(e) {

      localStorage.removeItem("login");
      localStorage.removeItem("password");

      if(me.loginform.remember.checked){
        localStorage.setItem("login",me.loginform.login.value);
        localStorage.setItem("password",me.loginform.password.value);
      }

      window.app.setState('wait');
      window.app.socket.emit('login',{
        login: me.loginform.login.value,
        password: me.loginform.password.value,
        mywidth: screen.width
      })

    }.bind(this);

    this.keypress = function(e) {
      var index;
      if (e.which === 13){
        index = inputOrder.indexOf(e.target.name);
        if (index<inputOrder.length-1){
          index++;
        }else{
          index=0;
          me.submit(e);
        }
        me.loginform[inputOrder[index]].focus()
      }
      return true;

    }.bind(this);

    me.on('mount', function(eventName) {
      me.loginform[inputOrder[0]].focus();
    })
  
});

riot.tag('wait', '<div class="container-fluid"> <div class="row"> <div class="col-md-12 text-center"> <div class="timer-loader-{ connected ? \'green\' : \'red\' }"> Loading… </div> </div> </div> </div>', function(opts) {
    var me = this;
    me.connected = window.app.connected;
    me.on('mount update unmount', function(eventName) {
      console.info(eventName)
      me.connected = window.app.connected;
    });
  
});
