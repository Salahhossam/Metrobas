package com.transportation.metrobas.chat;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessageReportRepository extends JpaRepository< MessageReports,Integer> {

}
