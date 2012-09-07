(function ($) {
  var CLOSE_CLASS = 'icon-remove';
  var CLOSE_BUTTON = '<i class="pull-right ' + CLOSE_CLASS + '"></i>';
  
  $.extend(true, window, {
    constants: {
      ANIMATION_DURATION: 200
    },
    utilities: {
      toggleCollapsed: toggleCollapsed,
      search: search,
      addAlert: addAlert,
      addTags: addTags
    },
    events: {
      tagListTextBoxKeyUp: tagListTextBoxKeyUp
    }
  });
    
  $(function() {
    //Enable alert closing
    $('.alert').each(function() {
      var alert = $(this);
      alert.prepend(CLOSE_BUTTON);
      alert.children('.' + CLOSE_CLASS).on('click.alert', function() { alert.remove(); });
    });
    
    //Attach submit click handlers
    //$(document).on('click.submit', 'a.submit', function() { $(this).closest('form').submit(); return false; });
    //$(document).on('click.submit', 'input.submit', function() { $(this).closest('form').submit(); });
    
    setAnchorTarget('_blank');
    embedVideo();
    attachTogglePost();
    
    $('.timeago').timeago();
  });
  
  $(document).ajaxComplete(function(event, request) {
    var error = request.getResponseHeader('Alert-Error-Message');
    if (error) utilities.addAlert(error, 'error');
    
    var warning = request.getResponseHeader('Alert-Warning-Message');
    if (warning) utilities.addAlert(warning, 'warning');
    
    var notice = request.getResponseHeader('Alert-Notice-Message');
    if (notice) utilities.addAlert(notice, 'notice');
    
    setAnchorTarget('_blank');

    $('.timeago').timeago();
  });
  
  //This has to be done client side due to server sanitization not allowing the 'target' attribute
  function setAnchorTarget(target) {
    $('a.' + target).attr('target', target);
  }

  //This has to be done client side due to server sanitization not allowing the 'iframe' attribute
  function embedVideo() {
    $('#stream').on('click.video', '.video', function() {
      if ($(this).children('iframe').length > 0) return; //There is a 4px region on the bottom of the div that can still be clicked after the video has started
      
      $(this).children().toggle(false); //Hide thumbnail and play button
      
      var embed_domain;
      if ($(this).hasClass('youtube')) {
        embed_domain = 'https://youtube.com/embed/';
      }
      else if ($(this).hasClass('vimeo')) {
        embed_domain = 'https://player.vimeo.com/video/';
      }
      if (embed_domain) {
        $(this).append('<iframe width="480" height="360" src="' + embed_domain + $(this).attr('src') + '?autoplay=1" frameborder="0"></iframe>');
      }
      
      var self = this;
      $('.video').each(function() { //Revert any playing videos back to static images
        if (this != self && $(this).children('iframe').length > 0) {
          $(this).children('iframe').remove();
          $(this).children().toggle(true); //Show thumbnail and play button
        }
      });
    });
  }

  function attachTogglePost() {
    $('#filtered_stream').on('click.toggle_post', '.expand_button, .collapse_button', function() {
      var collapse_post = $(this).hasClass('collapse_button');
      $(this).attr('href', $(this).attr('href').replace('collapse_post=' + (!collapse_post).toString(), 'collapse_post=' + collapse_post.toString()));
      $(this).toggleClass('expand_button').toggleClass('collapse_button');
      
      var post_content = $(this).closest('.post_item').find('.content');
      post_content.children().animate({ height: 'toggle' }, constants.ANIMATION_DURATION);
      post_content.append('<div class="loading_panel"></div>');
    });
  }
  
  function toggleCollapsed(sender, collapsedElement) {
    $(sender).children('.expand_button, .collapse_button').toggleclass('expand_button').toggleclass('collapse_button');
    $('#' + collapsedelement).animate({ height: 'toggle' }, constants.ANIMATION_DURATION);
  }
  
  function search(sender, path, query) {
    query = $.trim(query);
    $.ajax({
      url: path + '?search=' + encodeURIComponent(query),
      context: sender
    });
  }
  
  function addAlert(message, type) {
    var clientAlerts = $('#client_alerts');
    clientAlerts.append('<div class="alert ' + type + '">' + CLOSE_BUTTON + message + '</div>');
    clientAlerts.children('.alert').filter(':last').children('.' + CLOSE_CLASS).on('click.alert', function() { $(this).parent().remove(); });
  }
  
  function tagListTextBoxKeyUp(event, path, post_id) {
    var sender = event.srcElement;
    switch (event.keyCode) {
      case 13: //Enter
        if (post_id != undefined) {
          $('#post_' + post_id + '_add_tags').click();
        }
        break;
      case 27: //Escape
        if (post_id != undefined) {
          $('#post_' + post_id + '_show_add_tags').toggle(true);
          $('#post_' + post_id + '_add_tags').toggle(false);
          $(sender).toggle(false);
        }
        break;
      default:
        if (!(event.keyCode == 8 || //Backspace
          event.keyCode == 46 || //Delete
          String.fromCharCode(event.keyCode).match(/\w/))) {
          return;
        }
        
        var name = extractLast($(sender).val());
        if (name.length == 0) break;
        
        getAutocompleteTags(sender, path, name, post_id);
        return; //Do not remove the #autocomplete_tags div
    }
    $('#autocomplete_tags').remove();
  }

  function extractLast(term) {
    return split(term).pop();
  }
  
  function split(value, delimiter) {
    if (delimiter == undefined) delimiter = ',';
    splitRegex = new RegExp('\s*' + delimiter + '\s*');
    return value.split(splitRegex);
  }
  
  function getAutocompleteTags(sender, path, name, post_id) {
    name = $.trim(name);
    if (name.length == 0) return;
    
    $.ajax({
      url: path + '?name=' + encodeURIComponent(name) + (post_id != undefined ? '&post_id=' + post_id : ''),
      context: sender,
      success: function(data) {
        if ($('#post_' + post_id + '_tag_list_text_box').is(':hidden')) return; //The textbox has already been closed
        
        $('#autocomplete_tags').remove();
        if ($.trim(data).length > 0) {
          $(sender).after('<div id="autocomplete_tags">' + data + '</div>');
          $('#autocomplete_tags').append('<div class="clear"></div>');
        }
        
        $(document).one('click.close_autocomplete', ':not(#' + sender.id + ')', function() {
          $('#autocomplete_tags').remove();
        });
      }
    });
  }

  function addTags(sender, post_id, show) {
    $('#post_' + post_id + '_show_add_tags').toggle(!show);
    $('#post_' + post_id + '_add_tags').toggle(show);
    
    var tagListTextBox = $('#post_' + post_id + '_tag_list_text_box');
    tagListTextBox.toggle(show);
    if (show) {
      tagListTextBox.val('');
      tagListTextBox.focus();
    }
    else {
      sender.href += '&added_tags=' + encodeURIComponent(tagListTextBox.val());
    }
  }
})(jQuery);