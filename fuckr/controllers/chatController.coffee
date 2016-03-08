chatController = ($scope, $routeParams, chat, uploadImage) ->
    $scope.lastestConversations = chat.lastestConversations()

    $scope.open = (id) ->
        $scope.conversationId = id
        $scope.conversation = chat.getConversation(id)
        $scope.conversation.unread = false if $scope.conversation
        $scope.sentImages = null
    $scope.open($routeParams.id) if $routeParams.id

    $scope.$on 'new_message', ->
        $scope.conversation = chat.getConversation($scope.conversationId)
        $scope.lastestConversations = chat.lastestConversations()

    $scope.sendText = ->
        if $scope.message
            chat.sendText($scope.message, $scope.conversationId)
            $scope.message = ''

    $scope.showSentImages = ->
        $scope.sentImages = chat.sentImages
    
    $scope.$watch 'imageFile', ->
        if $scope.imageFile
            $scope.uploading = true
            uploadImage.uploadChatImage($scope.imageFile).then (imageHash) ->
                $scope.uploading = false
                chat.sentImages.push(imageHash) if imageHash

    $scope.sendImage = (imageHash) ->
        chat.sendImage(imageHash, $scope.conversationId)
        
    $scope.sendLocation = ->
        chat.sendLocation($scope.conversationId)

    $scope.block = ->
        if confirm('Sure you want to block him?')
            chat.block($scope.conversationId)
            $scope.conversationId = null
            $scope.lastestConversations = chat.lastestConversations()

    $scope.delete = ->
        if confirm('Sure you want to delete this conversation?')
            chat.delete($scope.conversationId)
            $scope.conversationId = null
            $scope.lastestConversations = chat.lastestConversations()

    [shiftDown, SHIFT, ENTER] = [false, 16, 13]
    $scope.onKeyUp = -> shiftDown = false if event.which is SHIFT
    $scope.onKeyDown = ->
        if event.which is SHIFT
            shiftDown = true
        else if event.which is ENTER and not shiftDown
            $scope.sendText()
            event.preventDefault()

    clipboard = require('nw.gui').Clipboard.get()
    $scope.copyToClipboard = ->
        text = $scope.conversation.messages
            .map (message) ->
                if message.text
                    message.text
                else if message.image
                    "http://cdns.grindr.com/grindr/chat/#{message.image}"
                else if message.location
                    "https://maps.google.com/?q=loc:#{message.location.lat},#{message.location.lon}"
            .join('\n\n')
        clipboard.set(text)

angular.
    module('chatController', ['ngRoute', 'file-model', 'chat', 'uploadImage']).
    controller('chatController', ['$scope', '$routeParams', 'chat', 'uploadImage', chatController])
