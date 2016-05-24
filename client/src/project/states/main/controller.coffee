angular.module 'Scrumble.settings'
.controller 'ProjectCtrl', (
  $scope
  TrelloClient
  Project
  ScrumbleUser2
) ->
  TrelloClient.get('/members/me/boards').then (response) ->
    $scope.boards = response.data

  Project.getUserProject().$promise
  .then (project) ->
    $scope.project = project
  .catch (err) ->
    $scope.project = new Project()

  $scope.saving = false
  $scope.selectedItemChange = (boardId) ->
    return unless boardId?
    $scope.saving = true
    Project.query
      filter:
        where:
          boardId: boardId
    .$promise.then (response) ->
      return response[0] if response.length > 0
      console.debug "No project with boardId #{boardId} found. Creating a new one"
      project = new Project()
      project.boardId = boardId
      project.name = _.find($scope.boards, (board) ->
        board.id is project.boardId
      ).name
      project.$save()
    .then (project) ->
      $scope.project = project
      $scope.saving = false
      ScrumbleUser2.setProject(projectId: project.id).$promise.then ->
        if not $scope.project.team.length > 0
          $scope.$emit 'project:update', {nextState: 'tab.team', params: projectId: project.id}
        else
          $scope.$emit 'project:update', nextState: 'tab.board'
    .catch (err) ->
      $scope.project.boardId = null
      console.warn err
      $scope.saving = false
