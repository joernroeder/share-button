$.fn.share = (opts) ->

  ###########################
  # Check if elements exist #
  ###########################

  if $(@).length is 0
    console.log "Share Button: No elements found."
    return


  #######################
  # Set Global Elements #
  #######################

  $head = $('head')
  $body = $('body')

  #########################
  # Iterate over elements #
  #########################

  $(@).each (i, el) ->

    ######################
    # Set Local Elements #
    ######################

    $sharer = $(@)


    #################
    # Configuration #
    #################

    ## Add unique class to each element and hide

    $sharer.addClass("sharer-#{i}")
    $sharer.hide()

    ## Set up options

    opts ?= {}
    config = {}

    ## Basic Configurations

    config.url    = opts.url || window.location.href
    config.text   = opts.text || $('meta[name=description]').attr('content') || ''
    config.app_id = opts.app_id
    config.title  = opts.title
    config.image  = opts.image
    config.flyout = opts.flyout || 'top center'

    ## UI Configurations

    config.loadStyles        = if opts.loadStyles? then opts.loadStyles else true
    config.icon_namespace    = opts.icon_namespace || 'entypo'
    config.button_color      = opts.color || '#333'
    config.button_background = opts.background || '#e1e1e1'
    config.button_icon       = opts.icon || 'export'
    config.button_text       = opts.button_text || 'Share'
    config.service_icons     = opts.service_icons || {}

    get_icon = (service) -> if config.service_icons[service] then config.service_icons[service] else service
    ## Network-Specific Configurations

    set_opt = (base,ext) -> if opts[base] then opts[base][ext] || config[ext] else config[ext]

    config.twitter_url  = set_opt('twitter', 'url')
    config.twitter_text = set_opt('twitter', 'text')
    config.fb_url       = set_opt('facebook', 'url')
    config.fb_title     = set_opt('facebook', 'title')
    config.fb_caption   = set_opt('facebook', 'caption')
    config.fb_text      = set_opt('facebook', 'text')
    config.fb_image     = set_opt('facebook', 'image')
    config.gplus_url    = set_opt('gplus', 'url')


    #############
    ## PRIVATE ##
    #############

    ## Selector Configuration
    config.selector = ".#{$sharer.attr('class').split(" ").join(".")}"

    ## Correct Common Errors
    config.twitter_text = encodeURIComponent(config.twitter_text)
    config.app_id = config.app_id.toString() if typeof config.app_id == 'integer'

    ###########################
    # Share URL Configuration #
    ###########################

    paths =
      twitter: "http://twitter.com/intent/tweet?text=#{config.twitter_text}&url=#{config.twitter_url}"
      facebook: "https://www.facebook.com/sharer/sharer.php?u=#{config.fb_url}"
      gplus: "https://plus.google.com/share?url=#{config.gplus_url}"


    ################
    # Inject Icons #
    ################

    if config.loadStyles and not $('link[href="http://weloveiconfonts.com/api/?family=#{config.icon_namespace}"]').length
      $("<link />").attr(
        rel: "stylesheet"
        href: "http://weloveiconfonts.com/api/?family=" + config.icon_namespace
      ).appendTo $("head")


    ################
    # Inject Fonts #
    ################

    if config.loadStyles and not $('link[href="http://fonts.googleapis.com/css?family=Lato:900"]').length
      $("<link />").attr(
        rel: "stylesheet"
        href: "http://fonts.googleapis.com/css?family=Lato:900"
      ).appendTo $("head")


    ##############
    # Inject CSS #
    ##############

    if config.loadStyles and not $("meta[name='sharer#{config.selector}']").length
      $('head').append(getStyles(config))
               .append("<meta name='sharer#{config.selector}'>")


    ###############
    # Inject HTML #
    ###############
    
    do =>
      html_str = "<label class='#{config.icon_namespace}-#{config.button_icon}'><span>#{config.button_text}</span></label><div class='social #{config.flyout}'><ul>"
      for service, path of paths
        html_str += "<li class='#{config.icon_namespace}-#{get_icon(service)}' data-network='#{service}'></li>"
      html_str += "</ul></div>"

      $(@).html html_str


    #######################
    # Set Up Facebook API #
    #######################

    if !window.FB && config.app_id && ($('#fb-root').length is 0)
      protocol = if ['http', 'https'].indexOf(window.location.href.split(':')[0]) is -1 then 'https://' else '//'
      $body.append("<div id='fb-root'></div><script>(function(a,b,c){var d,e=a.getElementsByTagName(b)[0];a.getElementById(c)||(d=a.createElement(b),d.id=c,d.src='#{protocol}connect.facebook.net/en_US/all.js#xfbml=1&appId=#{config.app_id}',e.parentNode.insertBefore(d,e))})(document,'script','facebook-jssdk');</script>")

    ##############################
    # Popup/Share Links & Events #
    ##############################

    parent  = $sharer.parent()
    bubbles = parent.find(".social")
    bubble  = parent.find("#{config.selector} .social")
    label   = $sharer.find('label')

    toggle = (e) ->
      e.stopPropagation()
      bubble.add(label).toggleClass('active')

    open = -> bubble.add(label).addClass('active')

    close = -> bubble.add(label).removeClass('active')

    click_link = ->
      link = paths[$(@).data('network')]
      if ($(@).data('network') == 'facebook') && config.app_id
        unless window.FB
          console.log "The Facebook JS SDK hasn't loaded yet."
          return

        window.FB.ui
          method: 'feed',
          name: config.fb_title
          link: config.fb_url
          picture: config.fb_image
          caption: config.fb_caption
          description: config.fb_text
      else
        window.open(link, 'targetWindow', 'toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable=yes,width=500,height=350')
      return false

    label.on 'click', toggle
    $sharer.find('li').on 'click', click_link

    $body.on 'click', -> bubbles.removeClass('active')

    setTimeout (=> $sharer.show()), 250

    # return a little API
    return {
      toggle: toggle.bind(@)
      open: open.bind(@)
      close: close.bind(@)
      options: config
      self: @
    }
