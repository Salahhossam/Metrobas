package com.transportation.metrobas.gtfs;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, String> {

    @Query("SELECT t FROM Trip t LEFT JOIN FETCH t.stopTimes")
    List<Trip> findAllWithStopTimes();
}
