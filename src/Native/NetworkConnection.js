var _lukewestby$network_connection$Native_NetworkConnection = (function () {
  function getIsConnected() {
    return window.navigator.onLine || false
  }

  function isConnected() {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function (callback) {
      callback(_elm_lang$core$Native_Scheduler.succeed(getIsConnected()))
    })
  }

  function onConnectionChange(toTask) {
  	return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
  		function performTask() {
  			_elm_lang$core$Native_Scheduler.rawSpawn(toTask(getIsConnected()))
  		}

      window.addEventListener('online', performTask)
      window.addEventListener('offline', performTask)

  		return function () {
  			window.removeEventListener('online', performTask)
        window.removeEventListener('offline', performTask)
  		}
  	})
  }

  return {
    isConnected: isConnected,
    onConnectionChange: onConnectionChange
  }
}())
