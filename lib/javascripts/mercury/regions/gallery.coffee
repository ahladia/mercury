#= require mercury/core/region

class Mercury.GalleryRegion extends Mercury.Region

  @define 'Mercury.GalleryRegion', 'gallery',
    uploadFile: 'appendSlide'

  className: 'mercury-gallery-region'

  elements:
    controls  : '.mercury-gallery-region-controls'
    slides    : '.slides'
    paginator : '.paginator'

  events:
    'click .mercury-gallery-region-controls em': 'removeSlide'
    'click .mercury-gallery-region-controls img': 'gotoSlide'


  build: ->
    @speed ||= 3000

    @append('<ul class="mercury-gallery-region-controls"></ul>')

    @index = 1
    @refresh()
    @addLink($(slide)) for slide in @images

    @delay(@speed, => @nextSlide())


  refresh: ->
    @images = @$('.slide').hide()
    @index = 1 if @index > @images.length
    @$(".slide:nth-child(#{@index})").show()
    @paginator.html(Array(@images.length + 1).join('<span>&bull;</span>'))
    @paginator.find("span:nth-child(#{@index})").addClass('active')


  nextSlide: ->
    @index += 1
    @refresh()
    @timeout = @delay(@speed, => @nextSlide())


  gotoSlide: (e) ->
    clearTimeout(@timeout)
    @index = $(e.target).closest('li').prevAll('li').length + 1
    @refresh()
    @timeout = @delay(@speed, => @nextSlide())


  addLink: (slide) ->
    src = slide.find('img').attr('src')
    @controls.append($("""<li><img src="#{src}"/><em>&times;</em></li>""").data(slide: slide))


  dropFile: (files) ->
    new Mercury.Uploader(files)


  appendSlide: (file) ->
    return unless file.isImage()
    slide = $("""<div class="slide"><img src="#{file.get('url')}"/></div>""")
    @slides.append(slide)
    @addLink(slide)
    @refresh()


  removeSlide: (e) ->
    return alert(@t("can't remove last slide")) if @images.length == 1
    el = $(e.target).closest('li')
    slide = el.data('slide')
    index = slide.prevAll('.slide').length + 1

    slide.remove()
    el.remove()

    if index < @index
      @index -= 1
    else if index == @index
      clearTimeout(@timeout)
      @timeout = @delay(@speed, => @nextSlide())

    @refresh()
