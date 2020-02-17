// 現在時刻をhtmlに表示
function showClock() {
   var nowTime = new Date();
   var nowHour = nowTime.getHours();
   nowHour = ("0" + nowHour).slice(-2);
   var nowMin  = nowTime.getMinutes();
   nowMin = ("0" + nowMin).slice(-2);
   var nowSec  = nowTime.getSeconds();
   nowSec = ("0" + nowSec).slice(-2);
   var time_msg = nowHour + ":" + nowMin + ":" + nowSec;
   document.getElementById("RealtimeClockArea").innerHTML = time_msg;
}
setInterval('showClock()',1000);