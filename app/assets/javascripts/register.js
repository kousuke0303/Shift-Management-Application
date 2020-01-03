// 現在日付をhtmlに表示
document.getElementById("RealDateArea").innerHTML = getDate();

function getDate() {
  var now = new Date();
  var year = now.getFullYear();
  var mon = now.getMonth()+1; //１を足すこと
  var day = now.getDate();
  var date_msg = year + "年" + mon + "月" + day + "日"
  return date_msg;
}

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