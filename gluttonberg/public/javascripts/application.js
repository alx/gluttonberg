var AssetBrowser = {
  overlay: null,
  dialog: null,
  load: function(link, markup) {
    // Set everthing up
    AssetBrowser.showOverlay();
    $("body").append(markup);
    AssetBrowser.browser = $("#assetsDialog");
    AssetBrowser.target = $("#" + $(link).attr("rel"));
    // Grab the various nodes we need
    AssetBrowser.display = AssetBrowser.browser.find("#assetsDisplay");
    AssetBrowser.offsets = AssetBrowser.browser.find("> *:not(#assetsDisplay)");
    // Calculate the offsets
    AssetBrowser.offsetHeight = 0;
    AssetBrowser.offsets.each(function(i, element) {
      AssetBrowser.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    AssetBrowser.resizeDisplay();
    $(window).resize(AssetBrowser.resizeDisplay);
    // Cancel button
    AssetBrowser.browser.find("#cancel").click(AssetBrowser.close);
    // Capture anchor clicks
    AssetBrowser.display.find("a").click(AssetBrowser.click);
  },
  resizeDisplay: function() {
    var newHeight = AssetBrowser.browser.innerHeight() - AssetBrowser.offsetHeight;
    AssetBrowser.display.height(newHeight);
  },
  showOverlay: function() {
    if (!AssetBrowser.overlay) {
      AssetBrowser.overlay = $('<div id="assetsDialogOverlay">&nbsp</div>');
      $("body").append(AssetBrowser.overlay);
    }
    else {
      AssetBrowser.overlay.css({display: "block"});
    }
  },
  close: function() {
    AssetBrowser.overlay.css({display: "none"});
    AssetBrowser.browser.remove();
  },
  updateDisplay: function(json) {
    AssetBrowser.display.html(json.markup);
    AssetBrowser.display.find("a").click(AssetBrowser.click);
  },
  click: function() {
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      AssetBrowser.target.attr("value", id);
      AssetBrowser.close();
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowser.updateDisplay);
    }
    return false;
  }
};

$(document).ready(function() {
  $("#templateSections").click(function(e) {
    var target = $(e.target);
    if (target.is("a")) {
      // Ewwww, heaps dodgy
      var entry = target.parent().parent().parent();
      if (target.hasClass("plus")) {
        // Set the index on these correctly. Use a regex to find the number in the ID and increment it.
        // Do the same for all the following entries.
        var clonedEntry = entry.clone();
        clonedEntry.find("input").val("");
        clonedEntry.insertAfter(entry);
      }
      else {
        entry.remove();
      }
      return false;
    }
  });
  
  $("#wrapper .assetBrowserLink").click(function() {
    var link = this;
    $.get(link.href, null, function(markup) {AssetBrowser.load(link, markup);});
    return false;
  });
});