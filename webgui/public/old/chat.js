var io = new RocketIO({channel: channel}).connect();

$(function(){
  $("#chat #btn_send").click(post);
  $("#chat #message").keydown(function(e){
    if(e.keyCode == 13) post();
  });
});

io.on("chat", function(data){
  var m = $("<li>").html(data.name + " : " +data.message);
  $("#chat #timeline").prepend(m);
  lines = $( "#chat #timeline li" )
  console.log( lines.length )
  if (lines.length > 40 ) lines.last().remove();
});

io.on("total", function(data){
  var m = $("<p>").html(data.message);
  $("#total").html(m);
});


function getTOTAL(){
$.getJSON( "http://joeyoung.local:5000/total", function( data ) {
   // console.log(data.total);
    var m = $("<p>").html(data.total);
  $("#total").html(m);
})
}


$(document).on('ready',function(){
  setInterval(getTOTAL, 2000);
});



io.on("connect", function(){
  console.log("connect!! "+io.session);
  $("#type").text("Connected");
});

io.on("disconnect", function(){
  console.log("disconnect!!");
  $("#type").text("Disconnected!!!");
});

io.on("*", function(event, data){ // catch all events
  console.log(event + " - " + JSON.stringify(data));
});

io.on("error", function(err){
  console.error(err);
});

var post = function(){
  var name = $("#chat #name").val();
  var message = $("#chat #message").val();
  if(message.length < 1) return;
  io.push("chat", {name: name, message: message});
  $("#chat #message").val("");
};
