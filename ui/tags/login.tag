<login>
  <div class="container-fluid">
    <div class="row">
      <div class="col-md-12">
        <div class="panel panel-default">
          <div class="panel-heading">
            <h3 class="panel-title">Anmelden</h3>
          </div>
          <div class="panel-body">

            <form id="loginform">
              <div class="form-group">
                <label for="inputLogin" class="col-sm-2 control-label">Login</label>
                <div class="col-sm-10">
                  <input
                    value={ login }
                    type="text"
                    name="login"
                    class="form-control"
                    id="inputLogin"
                    placeholder="Login"
                    onkeypress={keypress}
                    >
                </div>
              </div>
              <div class="form-group">
                <label for="inputPassword" class="col-sm-2 control-label">Passwort</label>
                <div class="col-sm-10">
                  <input
                    value={ password }
                    name="password"
                    type="password"
                    class="form-control"
                    placeholder="Password"
                    id="inputPassword"
                    onkeypress={keypress}>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                  <div class="checkbox">
                    <label>
                      <input name="remember" type="checkbox">merken
                    </label>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="col-sm-offset-2 col-sm-10">
                  <button type="button" class="btn btn-default" onclick={ submit }>Anmelden</button>
                </div>
              </div>
            <form>


          </div>
        </div>
      </div>
    </div>
  </div>
  <script>
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

    submit(e){

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
