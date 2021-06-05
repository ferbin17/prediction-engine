function convert_number_fields(){
  $('<div class="quantity-nav"><div class="quantity-button quantity-up">+</div><div class="quantity-button quantity-down">-</div></div>').insertBefore('.quantity input[side="left"]');
  $('<div class="quantity-nav"><div class="quantity-button quantity-up quantity-right">+</div><div class="quantity-button quantity-down quantity-right">-</div></div>').insertAfter('.quantity input[side="right"]');
  
  $('.quantity').each(function() {
    var spinner = jQuery(this),
      input = spinner.find('input[type="number"]'),
      btnUp = spinner.find('.quantity-up'),
      btnDown = spinner.find('.quantity-down'),
      min = input.attr('min'),
      max = input.attr('max');

    btnUp.click(function() {
      var oldValue = parseFloat(input.val());
      if (oldValue >= max) {
        var newVal = oldValue;
      } else {
        var newVal = oldValue + 1;
      }
      spinner.find("input").val(newVal);
      spinner.find("input").trigger("change");
    });

    btnDown.click(function() {
      var oldValue = parseFloat(input.val());
      if (oldValue <= min) {
        var newVal = oldValue;
      } else {
        var newVal = oldValue - 1;
      }
      spinner.find("input").val(newVal);
      spinner.find("input").trigger("change");
    });
  });
}

$("body").delegate(".predict-button", "click", function(){
  var spinner = $(this).parent().find('.spinner-border');
  var match_id = $(this).parent().find('#match_id').val();
  spinner.css("display", "inline-block");
  $.ajax({
    type: "GET",
    url: "/predictions/match_popup",
    data : {id: match_id},
    success: function() {
      spinner.hide();
    },
    error: function(){
      window.alert("something wrong!");
    }
  });
})