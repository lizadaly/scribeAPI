React = require 'react'
{Navigation} = require 'react-router'
{Link} = require 'react-router'
API = require 'lib/api'

GenericButton = require 'components/buttons/generic-button'
FetchSubjectsMixin = require 'lib/fetch-subjects-mixin'

module.exports = React.createClass
  displayName: "Browse"
  mixins: [Navigation, FetchSubjectsMixin]

  getDefaultProps: ->
    page: 1
    browse: true
    limit: 28
    type: 'root'
    
  componentDidUpdate: (prev_props) ->
    if prev_props.hash != @props.hash
      @_fetchByProps()
      
  getInitialState: ->
    subjects: []

  render: ->
    
    if @state.subjects_prev_page?
       prevButton = <Link to="/browse/#{@state.subjects_prev_page}">Previous</Link>
    else
       prevButton = <span/>
    if @state.subjects_next_page?
       nextButton = <Link to="/browse/#{@state.subjects_next_page}">Next</Link>      
    else
       nextButton = <span/>

    <div className="browse">
      <div className="browse-nav row">
        <div className="columns">{prevButton}</div>
        <div className="columns">{nextButton}</div>
      </div>
      <div className="browse-group columns">
          {
            subj_array = @state.subjects.slice(0)
            cols = []
            while (subj_array.length) 
              cols.push(subj_array.splice(0, 4))

            for col, i in cols
               <div className="row small-up-1 medium-up-2 large-up-4 align-center" key={i}>
                 {
                   for subj, index in col
                     <div className="column" key={index}>
                        <Link to="/view/index/#{subj.order}">
                           <img src={subj.location.thumbnail} width="200" height="200"/>
                        </Link>
                     </div>
                 }
               </div>
          }
      </div>
      <div className="browse-nav row">
        <div className="columns">{prevButton}</div>
        <div className="columns">{nextButton}</div>        
      </div>
   </div>
           

