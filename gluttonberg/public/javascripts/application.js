var AssetBrowser = {
  overlay: null,
  dialog: null,
  load: function(p, link, markup) {
    // Set everthing up
    AssetBrowser.showOverlay();
    $("body").append(markup);
    AssetBrowser.browser = $("#assetsDialog");
    AssetBrowser.target = $("#" + $(link).attr("rel"));
    AssetBrowser.nameDisplay = p.find("strong");
    // Grab the various nodes we need
    AssetBrowser.display = AssetBrowser.browser.find("#assetsDisplay");
    AssetBrowser.offsets = AssetBrowser.browser.find("> *:not(#assetsDisplay)");
    AssetBrowser.backControl = AssetBrowser.browser.find("#back a");
    AssetBrowser.backControl.css({display: "none"});
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
    AssetBrowser.backControl.click(AssetBrowser.back);
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
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowser.backURL = json.backURL;
      AssetBrowser.backControl.css({display: "block"});
    }
    AssetBrowser.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowser.display.html(markup);
    AssetBrowser.display.find("a").click(AssetBrowser.click);
  },
  click: function() {
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      console.log(AssetBrowser.target[0])
      AssetBrowser.target.attr("value", id);
      var name = target.find("h2").html();
      AssetBrowser.nameDisplay.html(name);
      AssetBrowser.close();
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowser.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowser.backURL) {
      $.get(AssetBrowser.backURL, null, AssetBrowser.updateDisplay);
      AssetBrowser.backURL = null;
      AssetBrowser.backControl.css({display: "none"});
    }
    return false;
  }
};

var AssetBrowserEx = {
  overlay: null,
  dialog: null,
  rootPageUrl: null,
  onAssetSelect: null,
  show: function(){
    // display the dialog and do it's stuff
    var self = this;
    $("body").append('<div id="asset_load_point">&nbsp</div>');
   //  $.get(this.root_page_url, null, function(markup){
   $("#asset_load_point").load(this.rootPageUrl + ' #assetsDialog', null, function(){
      //$("body").append(markup);
      self.load();
    });

  },
  load: function(/*p, link, markup */) {
    var self = this;
    // Set everthing up
    this.showOverlay();
    
    this.browser = $("#assetsDialog");

    // Grab the various nodes we need
    this.display = this.browser.find("#assetsDisplay");
    // $("#assetsDialog").dialog({height: 500, width: 500});
    //$('#assetsDialog').jqm({modal: true});
    //$.jqmShow();
    this.offsets = this.browser.find("> *:not(#assetsDisplay)");
    this.backControl = this.browser.find("#back a");
    this.backControl.css({display: "none"});
    // Calculate the offsets
    this.offsetHeight = 0;
    this.offsets.each(function(i, element) {
      self.offsetHeight += $(element).outerHeight();
    });
    // Initialize
    this.resizeDisplay();
    $(window).resize(this.resizeDisplay);
    $(window).scroll(this.resizeDisplay);
    // Cancel button
    this.browser.find("#cancel").click(this.close);
    // Capture anchor clicks
    this.display.find("a").click(this.click);
    this.backControl.click(this.back);
  },
  resizeDisplay: function() {
    var newHeight = AssetBrowserEx.browser.innerHeight() - AssetBrowserEx.offsetHeight;
    AssetBrowserEx.display.height(newHeight);
  },
  getScrollXY: function() {
    var scrOfX = 0, scrOfY = 0;
    if( typeof( window.pageYOffset ) == 'number' ) {
      //Netscape compliant
      scrOfY = window.pageYOffset;
      scrOfX = window.pageXOffset;
    } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
      //DOM compliant
      scrOfY = document.body.scrollTop;
      scrOfX = document.body.scrollLeft;
    } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
      //IE6 standards compliant mode
      scrOfY = document.documentElement.scrollTop;
      scrOfX = document.documentElement.scrollLeft;
    }
    return [ scrOfX, scrOfY ];
  },
  showOverlay: function() {
    if (!AssetBrowserEx.overlay) {
      AssetBrowserEx.overlay = $('<div id="assetsDialogOverlay">&nbsp</div>');
      $("body").append(AssetBrowserEx.overlay);
    }
    else {
      AssetBrowserEx.overlay.css({display: "block"});
    }
  },
  close: function() {
    AssetBrowserEx.overlay.css({display: "none"});
    AssetBrowserEx.browser.remove();
  },
  handleJSON: function(json) {
    if (json.backURL) {
      AssetBrowserEx.backURL = json.backURL;
      AssetBrowserEx.backControl.css({display: "block"});
    }
    AssetBrowserEx.updateDisplay(json.markup);
  },
  updateDisplay: function(markup) {
    AssetBrowserEx.display.html(markup);
    AssetBrowserEx.display.find("a").click(AssetBrowserEx.click);
  },
  click: function() {
    // "this" is the item being clicked!
    var target = $(this);
    if (target.is(".assetLink")) {
      var id = target.attr("href").match(/\d+$/);
      AssetBrowserEx.onAssetSelect(id);
      AssetBrowserEx.close();
    }
    else {
      $.getJSON(target.attr("href") + ".json", null, AssetBrowserEx.handleJSON);
    }
    return false;
  },
  back: function() {
    if (AssetBrowserEx.backURL) {
      $.get(AssetBrowserEx.backURL, null, AssetBrowserEx.updateDisplay);
      AssetBrowserEx.backURL = null;
      AssetBrowserEx.backControl.css({display: "none"});
    }
    return false;
  }
};

// Displays the Asset Browser popup. This allows the user to select an asset from the asset library
//   @config.rootUrl = The url to retieve the HTML for rendering the root library page (showing collections and asset types)
//   @config.current_page_url = the url for the page you want to start the browser at (maybe for a sepecific category or collection.
//   @config.onAssetSelect = the function to execute when somone clicks an asset
function showAssetBrowser(config){
  console.log('showAssetBrowser');
  console.log(config);

  AssetBrowserEx.rootPageUrl = config.rootUrl;
  AssetBrowserEx.onAssetSelect = config.onSelect;
  AssetBrowserEx.show();
}

function writeAssetToField(fieldId){
  field = $("#" + fieldId);
  field.attr("value", id);
}

function writeAssetToAssetCollection(assetId, assetCollectionUrl){
 $.ajax({
   type: "POST",
   url: assetCollectionUrl,
   data: "asset_id=" + assetId,
   success: function(){
     window.location.reload();
   },
   error: function(){
     alert('Adding the Asset failed, sorry.');
     window.location.reload();
   },
 });
}

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
  
//  $("#wrapper .assetBrowserLink").click(function() {
//    var p = $(this);
//    var link = p.find("a");
//    $.get(link.attr("href"), null, function(markup) {AssetBrowser.load(p, link, markup);});
//    return false;
//  });
});