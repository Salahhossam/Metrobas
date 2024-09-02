package com.transportation.metrobas.chat;

import com.transportation.metrobas.user.UserAdabter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatService chatService;
    private final UserAdabter userAdabter;

    @Autowired
    public ChatController(ChatService chatService, UserAdabter userAdabter) {
        this.userAdabter = userAdabter;
        this.chatService = chatService;
    }

    @GetMapping("/messages")
   public List<MessageDto> findAllMessages(){
        List<Message> messages = this.chatService.findAllChatMessages();
        List<MessageDto> messageDtos = new ArrayList<>();
        for(Message message : messages){
            messageDtos.add(new MessageDto(message.getMessageId(), message.getMessageContent() ,message.getMessageDate(), userAdabter.UserToDto(message.getUser())));
        }
        return messageDtos;
   }

   @PostMapping("/{userId}/message")
   public void sendMessage(@RequestParam("message") String message, @PathVariable("userId") int userId) {
        this.chatService.SaveMessage(message,userId);
   }

   @DeleteMapping("/message/{messageId}")
    public void deleteMessage(@PathVariable("messageId") int messageId){
        this.chatService.deleteMessage(messageId);
   }

}
