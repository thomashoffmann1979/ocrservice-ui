<app>
  <nav class="navbar navbar-default navbar-fixed-top">
    <div class="container-fluid">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-collapse-1">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="#"><i class="fa fa-envelope-o fa-lg"></i></a>
      </div>

      <div class="collapse navbar-collapse" id="bs-collapse-1">


        <discovery></discovery>
        <ul class="nav navbar-nav pull-right">
          <li><a href="#" onclick={ inspect }>Inspect</a></li>
          <li><a href="#" onclick={ exit }>Exit</a></li>
          <li>
            <a href="#">
              <i class="fa fa-wifi icon-{ connected ? (loggedin?'green':'yellow') : 'red' }"></i>
              &nbsp;{message}
            </a>
          </li>
        </ul>

      </div>
    </div>
  </nav>

  <br/>
  <br/>
  <br/>





      <wait class="{ wait ? 'show' : 'hide' }"></wait>
      <login class="{ login ? 'show' : 'hide' }"></login>
      <letter class="{ letter ? 'show' : 'hide' }"></letter>

    </div>
  </div>

  <script>

    var states = ['wait','login','letter'];
    for(var i=0;i<states.length;i++){
      this[states[i]] = false;
    }
    var me = this;


    setTimeout(function(){
      me.state = 'login';
      riot.update();
    },5000);

    inspect(e){
      require('nw.gui').Window.get().showDevTools();
    }

    exit(e){
      var gui = require('nw.gui');
      gui.App.quit();
    }


    window.app = me;

    setState(state){
      for(var i=0;i<states.length;i++){
        this[states[i]] = false;
      }
      this[state] = true;
      riot.update();
    }
    switchToAddress(url){
      if (typeof me.socket!=='undefined'){
        me.socket.close()
      }
      me.socket = io(url);
      me.socket.on('connect', me.socketConnect.bind(me) );
      me.socket.on('disconnect', me.socketDisconnect.bind(me) );
      me.socket.on('loginRequired', me.socketLoginRequired.bind(me) );
      me.socket.on('loginError', me.socketLoginError.bind(me) );
      me.socket.on('loginSuccess', me.socketLoginSuccess.bind(me) );

      me.socket.on('letter', me.socketLetter.bind(me) );
      me.socket.on('checked', me.socketChecked.bind(me) );
      me.socket.on('empty', me.socketEmpty.bind(me) );

    }

    socketConnect(){
      me.message = "Verbunden";
      me.connected=true;
      riot.update();
    }

    socketDisconnect(){
      me.message = "Verbindung suchen ...";
      me.connected=false;
      me.current = null;
      riot.update();
    }

    socketLoginError(msg){
      alert(msg);
      me.loggedin=false;

    }

    socketEmpty(msg){
      me.message = "Warte auf Sendung ...";
      riot.update();

    }

    setInterval(function(){
      if (me.message == "Warte auf Sendung ..."){
        window.app.socket.emit('send',true);
      }
    },5000);

    socketLoginSuccess(msg){
      me.message = "Warte auf Sendung ...";
      riot.update();
    }

    socketLetter(msg){
      console.log('socketLetter',msg);

      me.loggedin=true;
      me.message = "Sendung erfassen";
      if (me.current===null){
        me.current={};
      }
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
    }

    socketChecked(msg){
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
    }

    socketLoginRequired(){
      me.message = "Anmeldung benötigt";
      me.setState('login');
      me.loggedin=false;
      riot.update();
    }

    me.current = {};
    me.currentBoxes=[];
    me.currentBoxesOk=false;
    me.currentLoaded =false;
    me.socket;
    me.setState('wait');
  </script>
</app>
