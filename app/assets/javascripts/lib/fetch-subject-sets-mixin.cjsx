API              = require './api'

module.exports =

  fetchSubjectSetsBasedOnProps: (callback) ->

    # Establish a callback for after subjects are fetched - to apply additional state changes:
    postFetchCallback = (subject_sets) =>
      return if subject_sets.length == 0

      state = {}

      # If a specific subject id was indicated
      if @props.query.selected_subject_id?
        # Get the index of the specified subject in the (presumably first & only) subject set:
        state.subject_index = (ind for subj,ind in subject_sets[0].subjects when subj.id == @props.query.selected_subject_id )[0] ? 0

      # If taskKey specified, now's the time to set that too:
      state.taskKey = @props.query.mark_task_key if @props.query.mark_task_key

      subject = subject_sets[0].subjects?[0]
      if subject
        @updateBrowserState(subject)

      @setState state, () => # Any additional callbacks passed in
         callback() if callback?

    # Fetch by subject-set id?
    subject_set_id = @props.params.subject_set_id ? @props.query.subject_set_id
    if subject_set_id?
      @fetchSubjectSet subject_set_id, postFetchCallback

    # Fetch by identifier?
    else if @props.params.identifier
      # Fetch the subject sets related to this identifier
      @fetchSubjectSetByIdentifier @props.params.identifier, postFetchCallback

    # Fetch subject-sets by filters:
    else
      # Gather filters by which to query subject-sets
      params =
        group_id:                 @props.query.group_id ? null
      @fetchSubjectSets params, postFetchCallback


  orderSubjectsByOrder: (subject_sets) ->
    for subject_set in subject_sets
      subject_set.subjects = subject_set.subjects.sort (a,b) ->
        return if a.order >= b.order then 1 else -1
    subject_sets

  # Fetch a single subject-set (i.e. via SubjectSetsController#show)
  # Query hash added to prevent local mark from being re-transcribable.
  fetchSubjectSet: (subject_set_id, callback) ->
    request = API.type("subject_sets").get subject_set_id, {}
    request.then (set) =>
      @setState subjectSets: [set], () =>
        @fetchSubjectsForCurrentSubjectSet 1, null, callback

  # Fetch a single subject set by label identifier - LD
  fetchSubjectSetByIdentifier: (identifier, callback) ->
    request = API.type("subject_sets").get(identifier: identifier)
    request.then (set) =>
      @setState subjectSets: [set[0]], () =>
        @fetchSubjectsForCurrentSubjectSet 1, null, callback

  # This is the main fetch method for subject sets. (fetches via SubjectSetsController#index)
  fetchSubjectSets: (params, callback) ->
    params = $.extend(workflow_id: @getActiveWorkflow().id, params)
    _callback = (sets) =>

    # Apply defaults to unset params:
    _params = $.extend({
      limit: 10
      workflow_id: @getActiveWorkflow().id
      random: true
    }, params)
    # Strip null params:
    params = {}; params[k] = v for k,v of _params when v?

    API.type('subject_sets').get(params).then (sets) =>

      @setState subjectSets: sets, () =>
        @fetchSubjectsForCurrentSubjectSet 1, null, callback

  # PB: Setting default limit to 120 because it's a multiple of 3 mandated by thumb browser
  fetchSubjectsForCurrentSubjectSet: (page=1, limit=120, callback) ->
    ind = @state.subject_set_index
    sets = @state.subjectSets


    # page & limit not passed when called this way for some reason, so we have to manually construct query:
    # sets[ind].get('subjects', {page: page, limit: limit}).then (subjs) =>
    params =
      subject_set_id: sets[ind].id
      page: page
      limit: limit
      type: 'root'
      status: 'any'

    process_subjects = (subjs) =>
      sets[ind].subjects = subjs

      @updateBrowserState(subjs[0])

      @setState
        subjectSets:                sets
        subjects_current_page:      subjs[0].getMeta('current_page')
        subjects_total_pages:       subjs[0].getMeta('total_pages'), () =>
          callback? sets

    @_subject_queries ||= {}
    API.type('subjects').get(params).then (subjects) =>
      @_subject_queries[params] = subjects
      process_subjects subjects

  updateBrowserState: (subject) ->
    identifier = subject['meta_data'].identifier
    historyState = {subject: identifier}
    if window.history.state?['subject'] != identifier
      window.history.pushState({subject: identifier}, '', '/mark/' + identifier)



  # used by "About this {group}" link on Mark interface
  fetchGroups: ->
    API.type("groups").get(project_id: @props.project.id).then (groups)=>
      group.showButtons = false for group in groups  # hide buttons by default
      @setState groups: groups
