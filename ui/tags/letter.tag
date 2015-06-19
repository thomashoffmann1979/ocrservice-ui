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
              onblur={check}
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
              placeholder="PLZ"
              onkeypress={keypress}
              onblur={check}
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
              onkeypress={keypress}
              onblur={check}>
          </div>
        </div>


        <div class="form-group">

          <label for="inputHousenumber" class="col-sm-2 control-label">HN</label>
          <div class="col-sm-7">
            <input
              name='housenumber'
              value={ current.housenumber }
              type="text"
              class="form-control"
              placeholder="Hausnummer"
              id="inputHousenumber"
              onkeypress={keypress}
              onblur={check}>
          </div>
          <div class="col-sm-3">
            <input
              name='housenumberExtension'
              value={ current.housenumberExtension }
              type="text"
              class="form-control"
              placeholder="Hausnummer"
              onkeypress={keypress}
              onblur={check}>
          </div>
        </div>

      </div>

      <div class="col-md-4">


        <ul>
          <li each ={currentBoxes}>SG{sortiergang} SF{sortierfach}</li>
        </ul>

        <br/>
        <button accesskey="s"
          type="button"
          class="btn btn-{currentBoxesOk?'success':'default'}"
          onclick={ submit }
          >Speicher [S]</button>
        <button
          accesskey="n"
          type="button"
          class="btn btn-info"
          onclick={ skip } >Skip [N]</button>
        <button accesskey="b"
          type="button"
          class="btn btn-warning"
          onclick={ bad } >Bad [B]</button>
      </div>


    </div>
    <form>
    <br/>
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
      if (this.letterform.id.value.indexOf('.')==-1){
        me.currentBoxesOk = window.app.currentBoxesOk;
      }else{
        me.currentBoxesOk = false;
      }

      if (eventName==='mount'){
        try{
          me.letterform[inputOrder[0]].focus();
          me.letterform[inputOrder[0]].select();
        }catch(e){

        }
      }
    });


    submit(e){
      if (me.currentBoxesOk===true){
        me.message = "Senden ...";
        var data = {
          code: this.letterform.id.value,
          id: me.current.id,
          box: me.currentBoxes[0],
          town: this.current.town,
          zipCode: this.letterform.zipCode.value,
          street: this.letterform.street.value,
          housenumber: this.letterform.housenumber.value,
          housenumberExtension: this.letterform.housenumberExtension.value
        }
        window.app.message = "Senden ...";
        window.app.setState('wait');
        window.app.socket.emit('save',data);
        riot.update();
      }
    }

    check(e){
      var data = {
        code: this.letterform.id.value,
        id: me.current.id,
        zipCode: this.letterform.zipCode.value,
        street: this.letterform.street.value,
        housenumber: this.letterform.housenumber.value,
        housenumberExtension: this.letterform.housenumberExtension.value
      }
      console.log('check',data);
      window.app.socket.emit('check',data);
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
          if (me.currentBoxesOk===true){
            me.submit(e);
          }else{
            me.skip(e);
          }
          index=0;
        }
        this.letterform[inputOrder[index]].focus();
        this.letterform[inputOrder[index]].select();
      }
      console.log(e);
      return true;
    }

  </script>
</letter>
