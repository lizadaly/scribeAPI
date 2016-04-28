React = require("react")
API                           = require '../lib/api'
Project                       = require 'models/project.coffee'
BrowserWarning                = require './browser-warning'

{RouteHandler}                = require 'react-router'

window.API = API

App = React.createClass
  getInitialState: ->
    routerRunning:        false
    user:                 null
    loginProviders:       []
    subjectsTotalResults: 0

  componentDidMount: ->
    @fetchUser()

    # Calculate the total number of labels and remember that
    @fetchSubjectCount()

  fetchSubjectCount: ->
    _params =
      type: 'root'
      browse: true
      page: 1
      limit: 1
      
    API.type('subjects').get(_params).then (subjects) =>
      if subjects.length > 0
        @setState subjectsTotalResults: subjects[0].getMeta("total")  
      
  fetchUser:->
    @setState
      error: null
    request = $.getJSON "/current_user"

    request.done (result)=>
      if result?.data
        @setState
          user: result.data
      else

      if result?.meta?.providers
        @setState loginProviders: result.meta.providers

    request.fail (error)=>
      @setState
        loading:false
        error: "Having trouble logging you in"

  setTutorialComplete: ->
    previously_saved = @state.user?.tutorial_complete?

    # Immediately amend user object with tutorial_complete flag so that we can hide the Tutorial:
    @setState user: $.extend(@state.user ? {}, tutorial_complete: true)

    # Don't re-save user.tutorial_complete if already saved:
    return if previously_saved

    request = $.post "/tutorial_complete"
    request.fail (error)=>
      console.log "failed to set tutorial value for user"


  render: ->
    project = window.project
    return null if ! project?

    style = {}
    style.backgroundImage = "url(#{project.background})" if project.background?

    <div>

        <div>
          <BrowserWarning />
          <RouteHandler hash={window.location.hash} project={project} onCloseTutorial={@setTutorialComplete} user={@state.user}/>
        </div>

    </div>

module.exports = App
 
 
