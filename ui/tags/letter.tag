<letter>

  <div class="col-md-12">

    <div class="panel panel-success">
      <div class="panel-heading">
        <h3 class="panel-title">Sendung erfassen</h3>
      </div>
      <div class="panel-body">
        <form id="letterform">
          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">ID</span>
            <input id='id' value={ current.id } type="text" class="form-control" placeholder="ID" aria-describedby="basic-addon1">
          </div>

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">PLZ</span>
            <input id='zipCode' value={ current.zipCode } type="number" class="form-control" placeholder="PLZ" aria-describedby="basic-addon1">
          </div>

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">Strasse</span>
            <input id='street' value={ current.street } type="text" class="form-control" placeholder="Strasse" aria-describedby="basic-addon1">
          </div>

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">Hausnummer</span>
            <input id='housenumber' value={ current.housenumber } type="text" class="form-control" placeholder="Hausnummer" aria-describedby="basic-addon1">
          </div>

          <div class="input-group">
            <span class="input-group-addon" id="basic-addon1">Hausnummer Zusatz</span>
            <input id='housenumberExtension' value={ current.housenumberExtension } type="text" class="form-control" placeholder="Hausnummer" aria-describedby="basic-addon1">
          </div>

          <button type="button" class="btn btn-default" onclick={ submit } >Senden</button>
          <button type="button" class="btn btn-default" onclick={ skip } >Skip</button>

        <form>
      </div>
      <div class="panel-footer">
        <img class="letterimg" src={ current.inlineimage } />
      </div>
    </div>
  </div>

  <script>
    var me = this;
    var socket;

    var me = this;
    me.current = window.app.current;
    me.on('mount update unmount', function(eventName) {
      me.current = window.app.current;
    });


    submit(e){
      me.message = "Senden ...";
      data = {
        id: this.letterform.id.value,
        zipCode: this.letterform.zipCode.value,
        street: this.letterform.street.value,
        housenumber: this.letterform.housenumber.value
      }
      socket.emit('save',data);
      riot.update();
    }


    skip(e){
      window.app.message = "Senden ...";
      window.app.setState('wait');
      data = {
        id: this.letterform.id.value
      }
      window.app.socket.emit('setbad',data);
      riot.update();
    }

  </script>
</letter>
