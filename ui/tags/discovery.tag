<discovery>
  <ul class="nav navbar-nav">
    <li each={ serviceList } >
      <a href="#" onclick={ parent.switchTo } data-address={address}>{address}</a>
    </li>
  </ul>
  <script>

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

    goTo(address){
      if (address==='127.0.0.1'){
        address = 'localhost';
      }
      alert(address);
      window.app.switchToAddress( 'http://'+address+':'+me.serviceHash[ address ] )
    }

    switchTo(e){
      me.goTo(e.target.dataset.address);
    }

  </script>
</discovery>
