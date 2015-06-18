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
              aria-describedby="basic-addon1">
          </div>

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">Passwort</span>
            <input
              value={ password }
              name="password"
              type="password"
              class="form-control"
              placeholder="Password"
              aria-describedby="basic-addon1">
          </div>
          <button type="button" class="btn btn-default" onclick={ submit } >Senden</button>
        <form>
      </div>
    </div>
  </div>
  <script>
    this.login = ""
    this.password = ""
    submit(e){
      window.app.socket.emit('login',{
        login: this.loginform.login.value,
        password: this.loginform.password.value
      })
    }
  </script>
</login>
