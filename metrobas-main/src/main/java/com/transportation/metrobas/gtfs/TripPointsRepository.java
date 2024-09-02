package com.transportation.metrobas.gtfs;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripPointsRepository extends JpaRepository<TripPoints, Integer> {

    @Query("SELECT s FROM TripPoints s WHERE s.trip.tripId =:tripId")
    List<TripPoints> findByTripId(@Param("tripId") String tripId);
}
