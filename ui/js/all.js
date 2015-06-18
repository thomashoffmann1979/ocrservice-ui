riot.tag('app', '<nav class="navbar navbar-default navbar-fixed-top"> <div class="container-fluid"> <div class="navbar-header"> <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-collapse-1"> <span class="icon-bar"></span> <span class="icon-bar"></span> <span class="icon-bar"></span> </button> <a class="navbar-brand" href="#"><i class="fa fa-envelope-o fa-lg"></i></a> </div> <div class="collapse navbar-collapse" id="bs-collapse-1"> <discovery></discovery> <ul class="nav navbar-nav pull-right"> <li><a href="#" onclick="{ inspect }">Inspect</a></li> <li><a href="#" onclick="{ exit }">Exit</a></li> <li> <a href="#"> <i class="fa fa-wifi icon-{ connected ? (loggedin?\'green\':\'yellow\') : \'red\' }"></i>{message}</a> </li> </ul> </div> </div> </nav> <br> <br> <br> <div class="container-fluid"> <div class="row"> <wait class="{ wait ? \'show\' : \'hide\' }"></wait> <login class="{ login ? \'show\' : \'hide\' }"></login> <letter class="{ letter ? \'show\' : \'hide\' }"></letter> </div> </div>', function(opts) {

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
      console.log(msg);
      me.loggedin=true;
      me.message = "Sendung erfassen";
      me.current = msg;
      me.setState('letter');
      riot.update();
    }.bind(this);

    this.socketLoginRequired = function() {
      me.message = "Anmeldung benötigt";
      me.setState('login');
      me.loggedin=false;
      riot.update();
    }.bind(this);

    me.current;
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

riot.tag('letter', '<div class="col-md-12"> <div class="panel panel-success"> <div class="panel-heading"> <h3 class="panel-title">Sendung erfassen</h3> </div> <div class="panel-body"> <form id="letterform"> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">ID</span> <input name="id" value="{ current.id }" type="text" class="form-control" placeholder="ID" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">PLZ</span> <input name="zipCode" value="{ current.zipCode }" type="number" class="form-control" placeholder="PLZ" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">Strasse</span> <input name="street" value="{ current.street }" type="text" class="form-control" placeholder="Strasse" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">Hausnummer</span> <input name="housenumber" value="{ current.housenumber }" type="text" class="form-control" placeholder="Hausnummer" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">Hausnummer Zusatz</span> <input name="housenumberExtension" value="{ current.housenumberExtension }" type="text" class="form-control" placeholder="Hausnummer" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <button type="button" class="btn btn-default" onclick="{ submit }" >Senden</button> <button type="button" class="btn btn-default" onclick="{ skip }" >Skip</button> <form> </div> <div class="panel-footer"> <img class="letterimg" riot-src="{ current.inlineimage }"> </div> </div> </div>', function(opts) {
    var me = this;
    var socket;
    var me = this;
    var inputOrder = ['id','zipCode','street','housenumber','housenumberExtension'];
    me.current = window.app.current;
    me.on('mount update unmount', function(eventName) {
      me.current = window.app.current;
    });


    this.submit = function(e) {
      me.message = "Senden ...";
      data = {
        id: this.letterform.id.value,
        zipCode: this.letterform.zipCode.value,
        street: this.letterform.street.value,
        housenumber: this.letterform.housenumber.value
      }
      socket.emit('save',data);
      riot.update();
    }.bind(this);


    this.skip = function(e) {
      window.app.message = "Senden ...";
      window.app.setState('wait');
      data = {
        id: this.letterform.id.value
      }
      window.app.socket.emit('setbad',data);
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
        this.letterform[inputOrder[index]].focus()
      }
      console.log(e);
    }.bind(this);

  
});

riot.tag('login', '<div class="col-md-12"> <div class="panel panel-default"> <div class="panel-heading"> <h3 class="panel-title">Anmelden</h3> </div> <div class="panel-body"> <form id="loginform"> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">Login</span> <input value="{ login }" name="login" type="text" class="form-control" placeholder="Login" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <div class="input-group"> <span class="input-group-addon" id="basic-addon1">Passwort</span> <input value="{ password }" name="password" type="password" class="form-control" placeholder="Password" aria-describedby="basic-addon1" onkeypress="{keypress}"> </div> <button type="button" class="btn btn-default" onclick="{ submit }" >Senden</button> <form> </div> </div> </div>', function(opts) {
    var inputOrder = ['login','password'];
    var me = this;
    me.login = ""
    me.password = ""
    this.submit = function(e) {
      window.app.setState('wait');
      window.app.socket.emit('login',{
        login: me.loginform.login.value,
        password: me.loginform.password.value
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

riot.tag('wait', '<div class="col-md-12 text-center"> <div class="timer-loader-{ connected ? \'green\' : \'red\' }"> Loading… </div> </div>', function(opts) {
    var me = this;
    me.connected = window.app.connected;
    me.on('mount update unmount', function(eventName) {
      console.info(eventName)
      me.connected = window.app.connected;
    });
  
});
