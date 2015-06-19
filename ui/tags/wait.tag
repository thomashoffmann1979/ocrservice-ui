<wait>
  <div class="container-fluid">
    <div class="row">
  <div class="col-md-12 text-center">
    <div class="timer-loader-{ connected ? 'green' : 'red' }">
      Loading…
    </div>
  </div>
  </div>
</div>
  <script>
    var me = this;
    me.connected = window.app.connected;
    me.on('mount update unmount', function(eventName) {
      console.info(eventName)
      me.connected = window.app.connected;
    });
  </script>
</wait>
