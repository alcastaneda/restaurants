console.log('connected');

$(document).ready(function(){

  $('form').on("submit", function(event){
  event.preventDefault();
console.log('submit');
  $.ajax({
    url: "/results",
    data: $(this).serialize(),
    dataType: "html",
    success: function(data){
      $('#results').html(data);
    }
  });
});


$('input[type="submit"]').on("click", function(event){
  event.preventDefault();
  console.log('click');
  $.ajax({
    url: "/results",
    data: $('form').serialize(),
    dataType: "html",
    success: function(data){
      $('#results').html(data);
    }
  }).done()
});

$('body').on('click', function(){
  console.log("yooo");
});
});