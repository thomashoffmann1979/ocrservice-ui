<login>
  <div class="col-md-12">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h3 class="panel-title">Anmelden</h3>
      </div>
      <div class="panel-body">
        <form id="loginform">

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">Login</span>
            <input
              value={ login }
              name="login"
              type="text"
              class="form-control"
              placeholder="Login"
              aria-describedby="basic-addon1"
              onkeypress={keypress}>
          </div>

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">Passwort</span>
            <input
              value={ password }
              name="password"
              type="password"
              class="form-control"
              placeholder="Password"
              aria-describedby="basic-addon1"
              onkeypress={keypress}>
          </div>
          <button type="button" class="btn btn-default" onclick={ submit } >Senden</button>
        <form>
      </div>
    </div>
  </div>
  <script>
    var inputOrder = ['login','password'];
    var me = this;
    me.login = ""
    me.password = ""
    submit(e){
      window.app.setState('wait');
      window.app.socket.emit('login',{
        login: me.loginform.login.value,
        password: me.loginform.password.value
      })

    }

    keypress(e){
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
      //console.log(e);
    }

    me.on('mount', function(eventName) {
      me.loginform[inputOrder[0]].focus();
    })
  </script>
</login>
