package com.transportation.metrobas.chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Integer> {

    @Query("SELECT m FROM Message m ORDER BY m.messageDate DESC")
    List<Message> findAllChatMessagesSortedByDateDesc();
}
