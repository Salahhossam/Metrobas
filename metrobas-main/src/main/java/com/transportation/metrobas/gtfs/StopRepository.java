package com.transportation.metrobas.gtfs;

import com.transportation.metrobas.gtfs.Stop;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StopRepository extends JpaRepository<Stop, String> {
    @Query("SELECT s FROM Stop s " +
            "LEFT JOIN FETCH s.stopTimes st ")
    List<Stop> getAllStopsWithStopTimes();
}
