<letter>
  <div class="container-fluid" id="fluidform">
    <form id="letterform">
    <div class="row">

      <div class="col-md-4">
        <div class="form-group">
          <label for="inputID" class="col-sm-2 control-label">ID</label>
          <div class="col-sm-10">
            <input
              value={ current.id }
              type="text"
              name="id"
              class="form-control"
              id="inputID"
              placeholder="Login"
              onkeypress={keypress}
              >
          </div>
        </div>

        <div class="form-group">
          <label for="inputZipCode" class="col-sm-2 control-label">PLZ</label>
          <div class="col-sm-10">
            <input
              value={ current.zipCode }
              type="text"
              name="zipCode"
              class="form-control"
              id="inputZipCode"
              placeholder="Login"
              onkeypress={keypress}
              >
          </div>
        </div>

      </div>
      <div class="col-md-4">
        <div class="form-group">
          <label for="inputStreet" class="col-sm-2 control-label">Straße</label>
          <div class="col-sm-10">
            <input
              name='street'
              value={ current.street }
              type="text"
              class="form-control"
              placeholder="Strasse"
              id="inputStreet"
              onkeypress={keypress}>
          </div>
        </div>


        <div class="form-group">

          <label for="inputHousenumber" class="col-sm-2 control-label">HN/Zusatz</label>
          <div class="col-sm-7">
            <input
              name='housenumber'
              value={ current.housenumber }
              type="text"
              class="form-control"
              placeholder="Hausnummer"
              id="inputHousenumber"
              onkeypress={keypress}>
          </div>
          <div class="col-sm-3">
            <input
              name='housenumberExtension'
              value={ current.housenumberExtension }
              type="text"
              class="form-control"
              placeholder="Hausnummer"
              onkeypress={keypress}>
          </div>
        </div>

      </div>

      <div class="col-md-4">

                    <button type="button" class="btn btn-default" onclick={ submit } >Senden</button>
                    <button type="button" class="btn btn-default" onclick={ skip } >Skip</button>
                    <button type="button" class="btn btn-default" onclick={ bad } >Bad</button>
      </div>


    </div>
    <form>
  </div>

  <div class="container" >
    <div class="row">
      <img id="image" class="letterimg" height="300" src={ current.inlineimage } />
    </div>
  </div>

  <script>
    var me = this;
    var socket;
    var me = this;
    var inputOrder = ['id','zipCode','street','housenumber','housenumberExtension'];
    me.current = window.app.current;
    me.on('mount update unmount', function(eventName) {
      var img= window.document.getElementById('image');
      if (img!==null){
        img.height = $(window).height() - $('#fluidform').height() - 100;
      }
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
      window.app.socket.emit('skip',data);
      riot.update();
    }

    bad(e){
      window.app.message = "Senden ...";
      window.app.setState('wait');
      data = {
        id: this.letterform.id.value
      }
      window.app.socket.emit('bad',data);
      riot.update();
    }

    keypress(e){
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
    }

  </script>
</letter>
