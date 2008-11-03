$(document).ready(function() {
  var browser = $("#assetsDialog");
  if (browser.length > 0) {
    var display = browser.find("#assetsDisplay");
    var offsets = browser.find("> *:not(#assetsDisplay)");
    // Calculate the height used to calculate the display size
    var offsetHeight = 0;
    offsets.each(function(i, element) {
      offsetHeight += $(element).outerHeight();
    });
    // Resizes the display based on the offset
    var resizeDisplay = function() {
      var newHeight = browser.innerHeight() - offsetHeight;
      display.height(newHeight);
    };
    // Set the height straight away
    resizeDisplay();
    // Resize with the window
    $(window).resize(resizeDisplay);
    // TODO: Remove resize handler when dialog closes
  }
});