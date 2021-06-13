$(document).delegate("input.number_field", "keydown", function(e){
  if((e.which >= 96 && e.which <= 105) || [8, 37, 38, 39, 40, 33].includes(e.which) || (e.which >= 48 && e.which <= 57)){
    if((parseInt(String.fromCharCode(e.which)) != NaN) && !e.shiftKey){
      return true;
    }
  }
  return false;
})