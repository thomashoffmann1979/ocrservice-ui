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
            <a href="#"> <i class="fa fa-wifi icon-{ connected ? (loggedin?'green':'yellow') : 'red' }"></i>{message}</a>
          </li>
        </ul>

      </div>
    </div>
  </nav>

  <br/>
  <br/>
  <br/>



  <div class="container-fluid">
    <div class="row">

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
    //riot.route('customers/267393/edit')

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
      me.socket.on('letter', me.socketLetter.bind(me) );
      /*


      socket.on('sendings', me.socketSendings.bind(me) );
      socket.on('remove', me.socketRemove.bind(me) );
      socket.on('do', me.socketDo.bind(me) )
      socket.on('work', me.socketWork.bind(me) );
      */
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

    socketLetter(msg){
      console.log(msg);
      me.loggedin=true;
      me.message = "Sendung erfassen";
      me.current = msg;
      me.setState('letter');
      riot.update();
    }

    socketLoginRequired(){
      me.message = "Anmeldung benötigt";
      me.setState('login');
      me.loggedin=false;
      riot.update();
    }

    me.current;
    me.socket;
    me.setState('wait');
  </script>
</app>
