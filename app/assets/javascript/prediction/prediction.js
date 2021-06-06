$(document).delegate("input.number_field", "keydown", function(e){
  if((e.which >= 96 && e.which <= 105) || [8, 37, 38, 39, 40].includes(e.which)){
    return true
  }
  return false;
})